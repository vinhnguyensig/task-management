//
//  ShareService.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 13/9/24.
//

import Foundation

class ShareService {
    static let shared = ShareService()
    
    var currentSelectedDate: Date?
    var currentCategory: String?
}
