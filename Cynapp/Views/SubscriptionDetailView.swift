import SwiftUI

struct SubscriptionDetailView: View {
    let subscription: Subscription
    @StateObject private var viewModel = SubscriptionViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // En-tête
                VStack(spacing: 10) {
                    Text("Abonnement #\(subscription.shortId ?? subscription.id)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Statut: \(subscription.stripe.status)")
                        .font(.headline)
                        .foregroundColor(subscription.stripe.status == "active" ? .green : .orange)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("CynaBg"))
                .cornerRadius(12)
                
                // Résumé de l'abonnement
                VStack(alignment: .leading, spacing: 15) {
                    Text("Résumé de l'abonnement")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    ForEach(subscription.items) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.productId.label["fr"] ?? item.productId.label["en"] ?? "Produit")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Text("Quantité: \(item.stripe.quantity)")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(String(format: "%.2f", item.productId.priceMonthly))€/mois")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 5)
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Total Summary
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sous-total:")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(String(format: "%.2f", subscription.orderId.stripe.amountSubtotal))€")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("TVA:")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(String(format: "%.2f", subscription.orderId.stripe.amountTax))€")
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        HStack {
                            Text("Total:")
                                .font(.headline)
                            Spacer()
                            Text("\(String(format: "%.2f", subscription.orderId.stripe.amountTotal))€")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Informations de facturation
                if let address = subscription.orderId.billingAddress {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Informations de facturation")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Nom", value: address.name)
                            InfoRow(title: "Rue", value: address.street)
                            InfoRow(title: "Ville", value: address.city)
                            InfoRow(title: "Pays", value: address.country)
                            InfoRow(title: "Code postal", value: address.zipCode)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                // Informations de paiement
                VStack(alignment: .leading, spacing: 15) {
                    Text("Informations de paiement")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(title: "Méthode de paiement", value: subscription.stripe.defaultPaymentMethod)
                        InfoRow(title: "ID client", value: subscription.stripe.customerId)
                        InfoRow(title: "Période", value: "\(formatDate(subscription.stripe.periodStart)) - \(formatDate(subscription.stripe.periodEnd))")
                        
                        if let canceledAt = subscription.stripe.canceledAt {
                            InfoRow(title: "Annulé le", value: formatDate(canceledAt))
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Historique des statuts
                VStack(alignment: .leading, spacing: 15) {
                    Text("Historique des statuts")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    ForEach(subscription.statusHistory, id: \.id) { history in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(history.status)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text(history.details)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(formatDate(history.changedAt))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("Détails de l'abonnement")
        .onAppear {
            viewModel.fetchSubscriptionDetails(id: subscription.id)
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            outputFormatter.timeStyle = .short
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}



struct SubscriptionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubscriptionDetailView(subscription: Subscription(
                id: "test",
                stripe: StripeSubscriptionInfo(
                    subscriptionId: "sub_123",
                    status: "active",
                    periodStart: "2025-04-29T10:09:44.000Z",
                    periodEnd: "2025-05-29T10:09:44.000Z",
                    canceledAt: nil,
                    customerId: "cus_123",
                    defaultPaymentMethod: "pm_123",
                    latestInvoiceId: "in_123"
                ),
                user: SubscriptionUser(
                    id: "user_123",
                    firstName: "John",
                    lastName: "Doe",
                    email: "john@example.com"
                ),
                userEmail: "john@example.com",
                orderId: OrderInSubscription(
                    stripe: StripeInfo(
                        sessionId: "cs_123",
                        amountTotal: 100.0,
                        amountSubtotal: 80.0,
                        currency: "eur",
                        paymentMethod: "card",
                        paymentStatus: "paid",
                        voucherCode: nil,
                        amountTax: 20.0,
                        amountDiscount: 0.0,
                        invoiceId: "in_123",
                        paymentIntentId: nil,
                        subscriptionId: "sub_123"
                    ),
                    billingAddress: BillingAddress(
                        name: "John Doe",
                        country: "France",
                        city: "Paris",
                        zipCode: "75000",
                        street: "123 Rue Example"
                    ),
                    id: "order_123",
                    user: "user_123",
                    userEmail: "john@example.com",
                    products: [],
                    orderStatus: "PAID",
                    statusHistory: [],
                    createdAt: "2025-04-29T10:09:44.000Z",
                    updatedAt: "2025-04-29T10:09:44.000Z",
                    shortId: "TEST123"
                ),
                items: [],
                statusHistory: [],
                createdAt: "2025-04-29T10:09:44.000Z",
                updatedAt: "2025-04-29T10:09:44.000Z",
                shortId: "TEST123"
            ))
        }
    }
} 
