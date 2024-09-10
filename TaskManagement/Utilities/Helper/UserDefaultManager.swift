//
//  UserDefaultsManager.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import Foundation

class UserDefaultsManager {
    
    private init() {}
    
    static func save(value: Any?, forKey key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    static func get(forKey key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }
    
    // MARK: - Type-safe Accessors
    
    static func getString(forKey key: String) -> String {
        return get(forKey: key) as? String ?? ""
    }
    
    static func getStringOptional(forKey key: String) -> String? {
        return get(forKey: key) as? String
    }
    
    static func getNumber(forKey key: String) -> NSNumber {
        return get(forKey: key) as? NSNumber ?? NSNumber(value: 1)
    }
    
    static func getNumberOptional(forKey key: String) -> NSNumber? {
        return get(forKey: key) as? NSNumber
    }
    
    static func getBool(forKey key: String) -> Bool {
        return get(forKey: key) as? Bool ?? false
    }
    
    // MARK: - Removal
    
    static func remove(forKey key: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }
}
