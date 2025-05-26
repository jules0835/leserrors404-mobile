//
//  Categorie.swift
//  Cynapp
//
//  Created by Draskeer on 10/04/2025.
//

import Foundation

struct CategoryResponse: Codable {
    let categories: [Category]
    let total: Int
    let page: Int
    let size: Int
}

struct Category: Identifiable, Codable, Equatable {
    let id: String
    let label: [String: String]
    let description: [String: String]
    let isActive: Bool
    let picture: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case label
        case description
        case isActive
        case picture
    }
}

