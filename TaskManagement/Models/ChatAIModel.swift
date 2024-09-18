//
//  ChatAIModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 18/9/24.
//

import Foundation

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
}

struct ChatCompletionResponse: Codable {
    struct Choice: Codable {
        let message: OpenAIMessage
    }
    let choices: [Choice]
}
