//
//  Polling.swift
//  iChat
//
//  Created by 李子为 on 10/9/23.
//

import SwiftUI

extension ChatClient {

    // Setup timer
    func startPolling() {
        print("start polling")
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.handleFetchAndUpdateChats()
        }
    }

    func handleFetchAndUpdateChats() {
        Task {
            do {
                try await self.fetchAndUpdateChats()
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    // FIXED: weak self 解决循环引用问题

    // Fetching chat and update database
    func fetchAndUpdateChats() async throws {
        let sessions = self.GetSessions()
        print("sessions:")
        print(sessions)
        for session in sessions {
            fetchAndUpdateChat(chatSession: session)
        }
    }
    
    func fetchAndUpdateChat(chatSession: ChatSession) {
        let lastTime = GetLatestChatTime(sessionID: chatSession.id)
        let contentsDict = GetChatAPI(secretKey: chatSession.secretKey, lastTime: lastTime)
        // Insert into database
        for contentDict in contentsDict {
            if let time = contentDict["time"] as? Int64 {
                InsertMessage(sessionID: chatSession.id, isUser: false,  nickname: contentDict["user_nickname"] as? String ?? "",  message: contentDict["body"] as? String ?? "", dbTime: time)
            }
        }
    }
}


import Combine
import Foundation

/// A thread safe polling (repeat task over given time) handler object
public actor Polling {
    public typealias TaskItem = () async -> Void
    public typealias PollingTask = Task<Void, Never>
    typealias PollingSubject = CurrentValueSubject<Int, Never>

    private var pollingTask: PollingTask?
    private var pollingSubject = PollingSubject(0)

    public init() {}

    deinit {
        pollingTask?.cancel()
    }

    /// Start polling
    /// - Parameters:
    ///   - interval: Given time interval in seconds
    ///   - taskItem: A async closure task that will repeat over time
    public func start(_ interval: TimeInterval, taskItem: @escaping TaskItem) {
        /// Cancel previous task
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            /// One time perform on start
            print("in polling")
            await taskItem()

            guard let self, Task.isCancelled == false else {
                return
            }

            /// Create async sequence
            let asyncSequence = await pollingSubject
                .debounce(for: .seconds(interval), scheduler: DispatchQueue.global())
                .values

            /// Loop over async sequence
            for await _ in asyncSequence {
                /// Check task is canceled or not
                guard Task.isCancelled == false else {
                    return
                }
                /// Perform given task
                await taskItem()
                /// Trigger next iteration
                await pollingSubject.send(pollingSubject.value + 1)
                print("pollingSubject value: \(await pollingSubject.value)")
            }
        }
    }

    /// Stop polling
    public func stop() {
        pollingTask?.cancel()
    }
}

public extension Polling {
    /// Convenient way to start polling.
    /// - Parameters:
    ///   - interval: Given time interval
    ///   - taskItem: Given asynchronous task
    /// - Returns: An object of `CancelablePolling` you should hold this in memory as long as you interested in polling.
    static func startWith(_ interval: TimeInterval, taskItem: @escaping TaskItem) -> CancelablePolling {
        let task = Task {
            let polling = Polling()
            await polling.start(interval, taskItem: taskItem)
            return polling
        }
        return CancelablePolling(polling: task)
    }
}

// MARK: - CancelablePolling
public struct CancelablePolling: Cancellable {
    let polling: Task<Polling, Never>

    fileprivate init(polling: Task<Polling, Never>) {
        self.polling = polling
    }

    public func cancel() {
        Task {
            await polling.value.stop()
        }
    }
}
