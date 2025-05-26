import Foundation

struct OrdersResponse: Codable {
    let orders: [Order]
    let total: Int
}

struct Order: Identifiable, Codable {
    let id: String
    let shortId: String
    let user: OrderUser
    let userEmail: String
    let products: [OrderProduct]
    let stripe: StripeDetails
    let orderStatus: String
    let statusHistory: [StatusHistory]
    let billingAddress: BillingAddress
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case shortId
        case user
        case userEmail
        case products
        case stripe
        case orderStatus
        case statusHistory
        case billingAddress
        case createdAt
        case updatedAt
    }
}

struct OrderUser: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName
        case lastName
        case email
    }
}

struct OrderProduct: Codable {
    let productId: Product
    let quantity: Int
    let billingCycle: String
    let price: Double
    let stripePriceId: String
    let totalTax: Double
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case productId
        case quantity
        case billingCycle
        case price
        case stripePriceId
        case totalTax
        case id = "_id"
    }
}

struct StripeDetails: Codable {
    let sessionId: String
    let amountTotal: Double
    let amountSubtotal: Double
    let currency: String
    let paymentMethod: String
    let paymentStatus: String
    let voucherCode: String?
    let amountTax: Double
    let amountDiscount: Double
    let invoiceId: String
    let paymentIntentId: String?
    let subscriptionId: String?
}

struct StatusHistory: Codable {
    let status: String
    let updatedBy: String
    let details: String
    let id: String
    let changedAt: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case updatedBy
        case details
        case id = "_id"
        case changedAt
    }
}

struct BillingAddress: Codable {
    let name: String
    let country: String
    let city: String
    let zipCode: String
    let street: String
}

struct OrderItem: Codable, Identifiable {
    let id: String
    let product: Product
    let quantity: Int
    let price: Double
}

struct OrderListResponse: Codable {
    let orders: [Order]
}

struct StripeInfo: Codable {
    let sessionId: String
    let amountTotal: Double
    let amountSubtotal: Double
    let currency: String
    let paymentMethod: String
    let paymentStatus: String
    let voucherCode: String?
    let amountTax: Double
    let amountDiscount: Double
    let invoiceId: String
    let paymentIntentId: String?
    let subscriptionId: String?
}

struct OrderProductInSubscription: Codable, Identifiable {
    let id: String
    let productId: String
    let quantity: Int
    let price: Double
    let billingCycle: String
    let stripePriceId: String
    let totalTax: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case productId
        case quantity
        case price
        case billingCycle
        case stripePriceId
        case totalTax
    }
}

struct OrderInSubscription: Codable {
    let stripe: StripeInfo
    let billingAddress: BillingAddress?
    let id: String
    let user: String
    let userEmail: String
    let products: [OrderProductInSubscription]
    let orderStatus: String
    let statusHistory: [StatusHistory]
    let createdAt: String
    let updatedAt: String
    let shortId: String?
    
    enum CodingKeys: String, CodingKey {
        case stripe
        case billingAddress
        case id = "_id"
        case user
        case userEmail
        case products
        case orderStatus
        case statusHistory
        case createdAt
        case updatedAt
        case shortId
    }
} 