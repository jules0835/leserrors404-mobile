//
//  ProfileViewModel.swift
//  Cynapp
//
//  Created by Draskeer on 10/04/2025.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile
    
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
    }
    
    func logout() {
        // Logic to handle user logout (e.g., clearing session data)
    }
}
