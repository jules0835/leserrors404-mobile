import SwiftUI

struct SubscriptionListView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var selectedSubscription: Subscription?
    
    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Chargement des abonnements...")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else if viewModel.subscriptions.isEmpty {
                Text("Aucun abonnement trouvé")
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.subscriptions) { subscription in
                    Button(action: {
                        selectedSubscription = subscription
                    }) {
                        SubscriptionRow(subscription: subscription)
                    }
                }
            }
        }
        .navigationTitle("Mes Abonnements")
        .background(Color("CynaBg"))
        .onAppear {
            print("SubscriptionListView appeared, fetching subscriptions...")
            viewModel.fetchSubscriptions()
        }
        .sheet(item: $selectedSubscription) { subscription in
            NavigationView {
                SubscriptionDetailView(subscription: subscription)
            }
        }
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subscription #\(subscription.shortId ?? subscription.id)")
                .font(.headline)
            
            HStack {
                Text("Statut:")
                    .foregroundColor(.gray)
                Text(subscription.stripe.status)
                    .foregroundColor(subscription.stripe.status == "active" ? .green : .orange)
            }
            
            HStack {
                Text("Total:")
                    .foregroundColor(.gray)
                Text("\(String(format: "%.2f", subscription.orderId.stripe.amountTotal))€")
                    .fontWeight(.semibold)
            }
            
            Text(formatDate(subscription.createdAt))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            outputFormatter.timeStyle = .none
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

struct SubscriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubscriptionListView()
        }
    }
} 
