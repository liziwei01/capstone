//
//  Request.swift
//  iChat
//
//  Created by 李子为 on 9/21/23.
//

import SwiftUI

class SelfSignedSessionDelegate: NSObject, URLSessionDelegate {
	func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
			let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
			completionHandler(.useCredential, credential)
		} else {
			completionHandler(.performDefaultHandling, nil)
		}
	}
}

func GetRequest(url: URL, headers: [String: String]) -> [String: Any] {
	var request = URLRequest(url: url)
	request.allHTTPHeaderFields = headers
	request.httpMethod = "GET"

	let sessionDelegate = SelfSignedSessionDelegate()
	let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
	let semaphore = DispatchSemaphore(value: 0)

	var responseData: [String: Any] = [:]
	let task = session.dataTask(with: request) { (data, response, error) in
		defer { semaphore.signal() }

		if let error = error {
			print("Error: \(error.localizedDescription)")
			return
		}

		if let httpResponse = response as? HTTPURLResponse {
			if httpResponse.statusCode != 200 {
				print("Invalid response status code: \(httpResponse.statusCode)")
				return
			}
		}

		if let data = data {
			do {
				if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
					responseData = json
				}
			} catch {
				print("Error decoding JSON: \(error.localizedDescription)")
				return
			}
		}
	}

	task.resume()
	semaphore.wait()

	return responseData
}

func PostRequest(url: URL, headers: [String: String], body: Data) -> [String: Any] {
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = headers
    request.httpMethod = "POST"
    request.httpBody = body

    let sessionDelegate = SelfSignedSessionDelegate()
    let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
    let semaphore = DispatchSemaphore(value: 0)

    var responseData: [String: Any] = [:]
    let task = session.dataTask(with: request) { (data, response, error) in
        defer { semaphore.signal() }

        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }

        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 {
                print("Invalid response status code: \(httpResponse.statusCode)")
                return
            }
        }

        if let data = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    responseData = json
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                return
            }
        }
    }

    task.resume()
    semaphore.wait()

    return responseData
}

func SendChatAPI(secretKey: String, currentMessage: String, time: Int64)  -> [String: Any] {
    let keyNickname = HashString(from: secretKey)
    let contentDict: [String: Any] = ["user_nickname": conf.Nickname, "body": currentMessage]
    let oneTimeKey = GetHashedString(secretKey, time)
    if let jsonData = try? JSONSerialization.data(withJSONObject: contentDict, options: []),
       let base64Encoded = String(data: jsonData.base64EncodedData(), encoding: .utf8),
       let encryptedContent = AESEncryptWithString(input: base64Encoded, key: oneTimeKey) {
        let chatBodyDict: [String: Any] = [
            "data": [
                ["time": time, "content": encryptedContent]
            ]
        ]
        let postBody: [String: Any] = [
            "key_nickname": keyNickname,
            "chat_body": chatBodyDict
        ]

        if let postBodyData = try? JSONSerialization.data(withJSONObject: postBody, options: []) {
            let url = URL(string: String(format: conf.ServerIPPort + conf.PostChatRouterFormat))!
            let headers: [String: String] = ["Content-Type": "application/json"]
            return PostRequest(url: url, headers: headers, body: postBodyData)
        }
    }
    return [:]
}

func GetChatAPI(secretKey: String, lastTime: Int64) -> [[String: Any]] {
    let keyNickname = HashString(from: secretKey)
    let url = URL(string: String(format: conf.ServerIPPort + conf.GetChatRouterFormat, String(lastTime), String(keyNickname)))!
    let headers: [String: String] = [:]
    let responseData = GetRequest(url: url, headers: headers)
    var res: [[String: Any]] = []
    if let data = responseData["data"] as? [[String: Any]], responseData["errno"] as? Int == 0 {
        for chat in data {
            if let time = chat["time"] as? Int64, let content = chat["content"] as? String {
                // Check if the message is newer than the last message. If it is new, add it to the database
                // Decrypt to base64
                let oneTimeKey = GetHashedString(secretKey, time)
                let base64Encoded = AESDecryptWithString(input: content, key: oneTimeKey)
                // Decrypt to json
                if let base64Data = base64Encoded?.data(using: .utf8) {
                    if let decodedData = Data(base64Encoded: base64Data) {
                        do {
                            let jsonObject = try JSONSerialization.jsonObject(with: decodedData, options: [])
                            let contentDict = jsonObject as? [String: Any]
                            res.append(["user_nickname": contentDict?["user_nickname"] as? String ?? "", "body": contentDict?["body"] as? String ?? "", "time": time])
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    } else {
                        print("Error decoding base64 string.")
                    }
                }
            }
        }
    }
	// return slice like [["user_nickname": "123", "body": "Hello, world!", "time": 1234567890]]
	return res
}
