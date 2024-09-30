//
//  ChatAIViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 13/9/24.
//

import Foundation
import Combine

class ChatAIViewModel: ObservableObject {
    private var networkService: NetworkServiceProtocol
    
    @Published var chatMessages: [OpenAIMessage] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var responseMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkServiceProtocol = NetwordService.shared) {
        self.networkService = networkService
    }
    
    /// Fetches the chat completion for a single message and updates the UI.
    func fetchChatCompletion(singleMessage: String) async {
        guard !singleMessage.isEmpty else {
            errorMessage = "Please enter a message to send."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let userMessage = OpenAIMessage(role: "user", content: singleMessage)
        
        do {
            let response = try await networkService.fetchChat(messages: [userMessage])
            await MainActor.run { [weak self] in
                self?.responseMessage = response
                self?.isLoading = false
            }
        } catch {
            // Handle any network errors
            await MainActor.run { [weak self] in
                self?.isLoading = false
                if let networkError = error as? NetworkError {
                    self?.errorMessage = networkError.localizedDescription
                } else {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    /// Fetches the chat completion from OpenAI API and updates the UI.
    func fetchChatCompletion() async {
        guard !chatMessages.isEmpty else {
            errorMessage = "Please enter a message to send."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await networkService.fetchChat(messages: chatMessages)
            
            // Update the UI on the main thread
            await MainActor.run { [weak self] in
                self?.responseMessage = response
                self?.isLoading = false
                
                // Add the response to the chat history
                self?.chatMessages.append(OpenAIMessage(role: "assistant", content: response))
            }
        } catch {
            // Handle any network errors
            await MainActor.run { [weak self] in
                self?.isLoading = false
                if let networkError = error as? NetworkError {
                    self?.errorMessage = networkError.localizedDescription
                } else {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
