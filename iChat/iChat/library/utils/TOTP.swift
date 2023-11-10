//
//  TOTP.swift
//  iChat
//
//  Created by 李子为 on 10/11/23.
//

import SwiftUI
import CryptoKit

func GetHashedString(_ s: String, _ n: Int64) -> String {
    // Combine s and n into a single string
    let input = s + String(n)

    // Compute the SHA-1 hash value
    let h = Insecure.SHA1.hash(data: input.data(using: .utf8)!)

    // Convert the digest to an array of bytes
    var bytes = [UInt8](repeating: 0, count: 20) // Use 20 instead of h.count
    h.withUnsafeBytes {
        bytes = Array($0)
    }

    // Parse the first 6 bytes of the hash value as an int64
    var result: Int64 = 0
    for i in 0..<6 {
        result |= Int64(bytes[i]) << (40 - 8 * i)
    }

    // Take the result modulo 10^6 and format it with leading zeros
    return String(format: "%06d", result % 1_000_000)
}

func Now() -> Int64 {
    return Int64(Date().timeIntervalSince1970)
}
