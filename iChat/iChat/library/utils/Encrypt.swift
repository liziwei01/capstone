//
//  Encrypt.swift
//  iChat
//
//  Created by 李子为 on 10/11/23.
//

import SwiftUI
import CryptoKit

func AESEncryptWithString(input: String, key: String) -> String? {
//    let symmetricKey = SymmetricKey(data: key.data(using: .utf8)!)
    let symmetricKey = AESKey(from: key)!
    
    return AESEncrypt(input: input, symmetricKey: symmetricKey)
}

func AESEncrypt(input: String, symmetricKey: SymmetricKey) -> String? {
    guard let inputData = input.data(using: .utf8) else {
        return nil
    }
    
    do {
        let sealedBox = try AES.GCM.seal(inputData, using: symmetricKey)
        let combinedData = sealedBox.combined
        return combinedData?.base64EncodedString()
    } catch {
        print("Encryption failed: \(error.localizedDescription)")
        return nil
    }
}

func AESDecryptWithString(input: String, key: String) -> String? {
//    let symmetricKey = SymmetricKey(data: key.data(using: .utf8)!)
    let symmetricKey = AESKey(from: key)!
    
    return AESDecrypt(input: input, symmetricKey: symmetricKey)
}

func AESDecrypt(input: String, symmetricKey: SymmetricKey) -> String? {
    guard let inputData = Data(base64Encoded: input) else {
        return nil
    }
    
    do {
        let sealedBox = try AES.GCM.SealedBox(combined: inputData)
        let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
        return String(data: decryptedData, encoding: .utf8)
    } catch {
        print("Decryption failed: \(error.localizedDescription)")
        return nil
    }
}

func AESKey(from string: String) -> SymmetricKey? {
    // Ensure the input string is not empty
    guard !string.isEmpty else {
        print("KeyGen failed: Empty String")
        return nil
    }
    
    // Hash the string using SHA256, resulting in 32 bytes data, which is suitable for AES256
    let hash = Hash(from: string)
    
    // Convert the hash to a symmetric key
    let key = SymmetricKey(data: hash)
    
    return key
}

func HashString(from string: String) -> String {
	let hash = Hash(from: string)
	
	return hash.compactMap { String(format: "%02x", $0) }.joined()
}

func Hash(from string: String) -> SHA256Digest {
	guard let inputData = string.data(using: .utf8) else {
		return SHA256.hash(data: Data())
	}
	
	return SHA256.hash(data: inputData)
}

