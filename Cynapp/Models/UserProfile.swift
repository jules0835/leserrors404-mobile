//
//  UserProfile.swift
//  Cynapp
//
//  Created by Draskeer on 10/04/2025.
//
import Foundation

struct Address: Codable {
    let country: String
    let city: String
    let zipCode: String
    let street: String
}

struct Auth: Codable {
    let loginAttempts: Int
    let isOtpEnabled: Bool
}

struct Confirmation: Codable {
    let isConfirmed: Bool
}

struct Activation: Codable {
    let isActivated: Bool
    let inactivationDate: String?
    let inactivationReason: String?
}

struct Account: Codable {
    let auth: Auth?
    let confirmation: Confirmation?
    let activation: Activation?
}

struct UserProfile: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    
    let address: Address?
    let account: Account?
    
    let country: String?
    let city: String?
    let zipCode: String?
    let isActive: Bool?
    let isEmployee: Bool?
    let isAdmin: Bool?
    let createdAt: String?
    let company: String?
    let howDidYouHear: String?
    let isConfirmed: Bool?
    let isSuperAdmin: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName, lastName, email, phone, address, account, country, city, zipCode, isActive, isEmployee, isAdmin, createdAt, company, howDidYouHear, isConfirmed, isSuperAdmin
    }
}


