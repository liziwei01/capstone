//
//  Encrypt.swift
//  iChat
//
//  Created by 李子为 on 10/11/23.
//

import SwiftUI
import CryptoKit

func AESEncrypt(input: String, key: String) -> String? {
    guard let inputData = input.data(using: .utf8) else {
        return nil
    }
    
    let symmetricKey = SymmetricKey(data: key.data(using: .utf8)!)
    
    do {
        let sealedBox = try AES.GCM.seal(inputData, using: symmetricKey)
        let combinedData = sealedBox.combined
        return combinedData?.base64EncodedString()
    } catch {
        print("Encryption failed: \(error.localizedDescription)")
        return nil
    }
}

func AESDecrypt(input: String, key: String) -> String? {
    guard let inputData = Data(base64Encoded: input) else {
        return nil
    }
    
    let symmetricKey = SymmetricKey(data: key.data(using: .utf8)!)
    
    do {
        let sealedBox = try AES.GCM.SealedBox(combined: inputData)
        let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
        return String(data: decryptedData, encoding: .utf8)
    } catch {
        print("Decryption failed: \(error.localizedDescription)")
        return nil
    }
}


