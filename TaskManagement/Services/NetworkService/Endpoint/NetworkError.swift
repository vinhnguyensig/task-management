//
//  NetworkError.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 13/9/24.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case requestFailed(description: String)
    case decodingFailed(description: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .requestFailed(let description):
            return "Request failed: \(description)"
        case .decodingFailed(let description):
            return "Decoding failed: \(description)"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .invalidURL:
            return "The URL provided is not properly formatted or does not exist."
        case .requestFailed:
            return "The network request was not successful."
        case .decodingFailed:
            return "The data could not be decoded correctly."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "Please check the URL and try again."
        case .requestFailed:
            return "Please check your internet connection or try again later."
        case .decodingFailed:
            return "Ensure the data format is correct or contact support."
        }
    }
}
