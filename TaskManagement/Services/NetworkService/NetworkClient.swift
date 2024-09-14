//
//  NetworkClient.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation
import Alamofire

class NetworkClient {
    static let shared = NetworkClient()
    
    func fetchChatCompletionsAsync(messages: [OpenAIMessage]) async throws -> String {
        let endpoint = OpenAIAPIEndpoint.chatCompletions(messages: messages)
        
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: endpoint.method, parameters: endpoint.parameters, encoding: JSONEncoding.default, headers: endpoint.headers)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: ChatCompletionResponse.self, decoder: JSONDecoder()) { response in
                    switch response.result {
                    case .success(let chatResponse):
                        if let firstMessage = chatResponse.choices.first?.message.content {
                            continuation.resume(returning: firstMessage)
                        } else {
                            continuation.resume(throwing: NetworkError.decodingFailed(description: "No message found in the response"))
                        }
                    case .failure(let error):
                        continuation.resume(throwing: NetworkError.requestFailed(description: error.localizedDescription))
                    }
                }
        }
    }
}
