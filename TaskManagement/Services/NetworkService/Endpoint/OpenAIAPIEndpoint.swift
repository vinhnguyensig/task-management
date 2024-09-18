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
    static let model = "gpt-4o-mini"
}

enum OpenAIAPIEndpoint {
    case chatCompletions(messages: [OpenAIMessage])
    
    var apiKey: String {
        if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let apiKey = dict["OpenAIKey"] as? String {
           return apiKey
        } else {
            print("API key not found")
            return ""
        }
    }
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
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
    }
}
