//
//  SignInViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 18/9/24.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class SignInViewModel: ObservableObject {
    @Published var user: UserModel? = nil
    @Published var errorMessage: String? = nil
    
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        self.authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.user = UserModel(user: user)
            } else {
                self?.user = nil
            }
        }
    }
    
    deinit {
        if let handle = self.authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.errorMessage = "Failed to retrieve client ID"
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.errorMessage = "Failed to retrieve Google user or token"
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                if let firebaseUser = authResult?.user {
                    self?.user = UserModel(user: firebaseUser)
                    self?.errorMessage = nil
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            self.user = nil
            self.errorMessage = nil  // Clear error message on successful sign-out
        } catch let signOutError as NSError {
            self.errorMessage = "Error signing out: \(signOutError.localizedDescription)"
        }
    }
}
