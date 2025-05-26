//
//  Cart.swift
//  Cynapp
//
//  Created by Draskeer on 10/04/2025.
//

struct CartResponse: Codable {
    let checkout: Checkout
    let id: String
    let user: String
    let products: [ProductInCart]
    let subtotal, tax, discount, total: Double
    let createdAt, updatedAt: String
    let v: Int

    enum CodingKeys: String, CodingKey {
        case checkout
        case id = "_id"
        case user, products, subtotal, tax, discount, total
        case createdAt, updatedAt
        case v = "__v"
    }
}

struct Checkout: Codable {
    let isEligible: Bool
    let reason: String
}

struct ProductInCart: Codable {
    let product: Product
    let quantity: Int
    let billingCycle: String
    let id: String

    enum CodingKeys: String, CodingKey {
        case product
        case quantity
        case billingCycle
        case id = "_id"
    }
}
