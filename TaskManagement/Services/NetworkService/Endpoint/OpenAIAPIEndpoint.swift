//
//  OpenAIAPIEndpoint.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 13/9/24.
//

import Foundation
import Alamofire

struct OpenAIAPIConstants {
    static let baseURL = "https://api.openai.com"
    static let apiKey = "sk-tpbPH5oEW7SqvQICnAOwy0Jv8DpSQYNwj379m6ESXoT3BlbkFJ6O3vu7v3gewlBJwoiP7tmKM_niEBF_xTgKha" // Store this securely
    static let model = "gpt-4-mini"
}

enum OpenAIAPIEndpoint {
    case chatCompletions(messages: [OpenAIMessage])
    
    var path: String {
        switch self {
        case .chatCompletions:
            return "/v1/chat/completions"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .chatCompletions:
            return .post
        }
    }
    
    var url: URL? {
        return URL(string: OpenAIAPIConstants.baseURL + path)
    }
    
    /// Constructs the parameters for the API request.
    var parameters: [String: Any] {
        switch self {
        case .chatCompletions(let messages):
            let encodedMessages = messages.map { ["role": $0.role, "content": $0.content] }
            return [
                "model": OpenAIAPIConstants.model,
                "messages": encodedMessages
            ]
        }
    }
    
    /// Sets the headers for the API request.
    var headers: HTTPHeaders {
        return [
            "Authorization": "Bearer \(OpenAIAPIConstants.apiKey)",
            "Content-Type": "application/json"
        ]
    }
}

/// A message structure for OpenAI API interactions.
struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

/// Structure for making chat completion requests to OpenAI.
struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
}

/// Structure for parsing chat completion responses from OpenAI.
struct ChatCompletionResponse: Codable {
    struct Choice: Codable {
        let message: OpenAIMessage
    }
    let choices: [Choice]
}
