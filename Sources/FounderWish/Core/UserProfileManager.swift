//
//  UserProfileManager.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation

@available(iOS 15.0, *)
actor UserProfileManager {
    static let shared = UserProfileManager()
    
    private let userIDKey = "com.founderwish.userIdentifier"
    private let installDateKey = "com.founderwish.installDate"
    
    func getUserIdentifier() -> String {
        if let existing = UserDefaults.standard.string(forKey: userIDKey) {
            return existing
        }
        
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: userIDKey)
        return newID
    }
    
    func getInstallDate() -> Date {
        if let existing = UserDefaults.standard.object(forKey: installDateKey) as? Date {
            return existing
        }
        
        let installDate = Date()
        UserDefaults.standard.set(installDate, forKey: installDateKey)
        return installDate
    }
}

