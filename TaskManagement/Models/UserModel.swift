//
//  UserModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 18/9/24.
//

import Foundation
import FirebaseAuth

struct UserModel {
    let uid: String
    let displayName: String?
    let email: String?
    let photoURL: URL?
    let phoneNumber: String?
    
    init(user: User) {
        self.uid = user.uid
        self.displayName = user.displayName
        self.email = user.email
        self.photoURL = user.photoURL
        self.phoneNumber = user.phoneNumber
    }
}
