import Foundation

struct SubscriptionsResponse: Codable {
    let subscriptions: [Subscription]
    let total: Int
}

struct Subscription: Codable, Identifiable {
    let id: String
    let stripe: StripeSubscriptionInfo
    let user: SubscriptionUser
    let userEmail: String
    let orderId: OrderInSubscription
    let items: [SubscriptionItem]
    let statusHistory: [StatusHistory]
    let createdAt: String
    let updatedAt: String
    let shortId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case stripe
        case user
        case userEmail
        case orderId
        case items
        case statusHistory
        case createdAt
        case updatedAt
        case shortId
    }
}

struct SubscriptionUser: Codable {
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

struct StripeSubscriptionInfo: Codable {
    let subscriptionId: String
    let status: String
    let periodStart: String
    let periodEnd: String
    let canceledAt: String?
    let customerId: String
    let defaultPaymentMethod: String
    let latestInvoiceId: String
}

struct ProductDetail: Codable, Identifiable {
    let id: String
    let label: [String: String]
    let description: [String: String]
    let characteristics: [String: [String]]
    let categorie: String
    let stock: Int
    let price: Double?
    let priceMonthly: Double
    let priceAnnual: Double
    let stripeTaxId: String
    let stripeProductId: String
    let stripePriceIdMonthly: String
    let stripePriceIdAnnual: String
    let stripePriceId: String?
    let taxe: Double
    let subscription: Bool
    let priority: Int
    let similarProducts: [String]
    let isActive: Bool
    let picture: String
    let shortId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case label
        case description
        case characteristics
        case categorie
        case stock
        case price
        case priceMonthly
        case priceAnnual
        case stripeTaxId
        case stripeProductId
        case stripePriceIdMonthly
        case stripePriceIdAnnual
        case stripePriceId
        case taxe
        case subscription
        case priority
        case similarProducts
        case isActive
        case picture
        case shortId
    }
}

struct SubscriptionItem: Codable, Identifiable {
    let id: String
    let stripe: StripeItemInfo
    let productId: ProductDetail
    let billingCycle: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case stripe
        case productId
        case billingCycle
    }
}

struct StripeItemInfo: Codable {
    let priceId: String
    let itemId: String
    let quantity: Int
} 