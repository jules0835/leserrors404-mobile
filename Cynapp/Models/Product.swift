struct Product: Identifiable, Codable {
    let _id: String
    let label: [String: String]
    let description: [String: String]
    let characteristics: [String: String]
    let categorie: String
    let stock: Int
    let price: Double
    let priceMonthly: Double?
    let priceAnnual: Double?
    let taxe: Double
    let subscription: Bool
    let priority: Int?
    let similarProducts: [String]
    let isActive: Bool
    let picture: String
    let stripeTaxId: String?
    let stripeProductId: String?
    let stripePriceIdMonthly: String?
    let stripePriceIdAnnual: String?
    let stripePriceId: String?

    var id: String { _id }

    enum CodingKeys: String, CodingKey {
        case _id
        case label
        case description
        case characteristics
        case categorie
        case stock
        case price
        case priceMonthly
        case priceAnnual
        case taxe
        case subscription
        case priority
        case similarProducts
        case isActive
        case picture
        case stripeTaxId
        case stripeProductId
        case stripePriceIdMonthly
        case stripePriceIdAnnual
        case stripePriceId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try container.decode(String.self, forKey: ._id)
        label = try container.decode([String: String].self, forKey: .label)
        description = try container.decode([String: String].self, forKey: .description)
        
        if let rawCharacteristics = try? container.decodeIfPresent([String: String].self, forKey: .characteristics) {
            characteristics = rawCharacteristics ?? [:]
        } else if let rawCharacteristics = try? container.decodeIfPresent([String: [String]].self, forKey: .characteristics) {
            var temp: [String: String] = [:]
            for (key, valueArray) in rawCharacteristics ?? [:] {
                temp[key] = valueArray.joined(separator: "\n") // tu peux adapter le séparateur si tu veux
            }
            characteristics = temp
        } else {
            characteristics = [:]
        }

        categorie = try container.decode(String.self, forKey: .categorie)
        stock = try container.decode(Int.self, forKey: .stock)
        price = try container.decodeIfPresent(Double.self, forKey: .price) ?? 0.0
        priceMonthly = try container.decodeIfPresent(Double.self, forKey: .priceMonthly) ?? 0.0
        priceAnnual = try container.decodeIfPresent(Double.self, forKey: .priceAnnual) ?? 0.0
        taxe = try container.decode(Double.self, forKey: .taxe)
        subscription = try container.decode(Bool.self, forKey: .subscription)
        priority = try container.decodeIfPresent(Int.self, forKey: .priority)
        similarProducts = try container.decode([String].self, forKey: .similarProducts)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        picture = try container.decode(String.self, forKey: .picture)
        stripeTaxId = try container.decodeIfPresent(String.self, forKey: .stripeTaxId)
        stripeProductId = try container.decodeIfPresent(String.self, forKey: .stripeProductId)
        stripePriceIdMonthly = try container.decodeIfPresent(String.self, forKey: .stripePriceIdMonthly)
        stripePriceIdAnnual = try container.decodeIfPresent(String.self, forKey: .stripePriceIdAnnual)
        stripePriceId = try container.decodeIfPresent(String.self, forKey: .stripePriceId)
    }

    init(
        _id: String,
        label: [String: String],
        description: [String: String],
        characteristics: [String: String],
        categorie: String,
        stock: Int,
        price: Double,
        priceMonthly: Double,
        priceAnnual: Double,
        taxe: Double,
        subscription: Bool,
        priority: Int? = nil,
        similarProducts: [String],
        isActive: Bool,
        picture: String,
        stripeTaxId: String? = nil,
        stripeProductId: String? = nil,
        stripePriceIdMonthly: String? = nil,
        stripePriceIdAnnual: String? = nil,
        stripePriceId: String? = nil
    ) {
        self._id = _id
        self.label = label
        self.description = description
        self.characteristics = characteristics
        self.categorie = categorie
        self.stock = stock
        self.price = price
        self.priceMonthly = priceMonthly
        self.priceAnnual = priceAnnual
        self.taxe = taxe
        self.subscription = subscription
        self.priority = priority
        self.similarProducts = similarProducts
        self.isActive = isActive
        self.picture = picture
        self.stripeTaxId = stripeTaxId
        self.stripeProductId = stripeProductId
        self.stripePriceIdMonthly = stripePriceIdMonthly
        self.stripePriceIdAnnual = stripePriceIdAnnual
        self.stripePriceId = stripePriceId
    }
}
