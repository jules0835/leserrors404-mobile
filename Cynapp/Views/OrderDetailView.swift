import SwiftUI

struct OrderDetailView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @State private var showInvoice = false
    let orderId: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if orderViewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading order details...")
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = orderViewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let order = orderViewModel.selectedOrder {
                    // Order Header
                    VStack(spacing: 10) {
                        Text("Order #\(order.shortId)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Status: \(order.orderStatus)")
                            .font(.headline)
                            .foregroundColor(order.orderStatus == "PAID" ? .green : .orange)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("CynaBg"))
                    .cornerRadius(12)
                    
                    // Order Summary
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Order Summary")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        ForEach(order.products, id: \.id) { product in
                            ProductOrderRow(product: product)
                        }
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        // Total Summary
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Subtotal:")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(String(format: "%.2f", order.stripe.amountSubtotal))€")
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("Tax:")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(String(format: "%.2f", order.stripe.amountTax))€")
                                    .fontWeight(.semibold)
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            HStack {
                                Text("Total:")
                                    .font(.headline)
                                Spacer()
                                Text("\(String(format: "%.2f", order.stripe.amountTotal))€")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // Billing Information
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Billing Information")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Name", value: order.billingAddress.name)
                            InfoRow(title: "Street", value: order.billingAddress.street)
                            InfoRow(title: "City", value: order.billingAddress.city)
                            InfoRow(title: "Country", value: order.billingAddress.country)
                            InfoRow(title: "ZIP Code", value: order.billingAddress.zipCode)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // Payment Information
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Payment Information")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Payment Method", value: order.stripe.paymentMethod.capitalized)
                            InfoRow(title: "Payment Status", value: order.stripe.paymentStatus.capitalized)
                            
                            Button(action: {
                                orderViewModel.fetchInvoiceUrl(invoiceId: order.stripe.invoiceId)
                                showInvoice = true
                            }) {
                                HStack {
                                    Text("View Invoice")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "doc.text")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color("CynaBg"))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // Order History
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Order History")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        ForEach(order.statusHistory, id: \.id) { history in
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
                } else {
                    VStack {
                        Image(systemName: "questionmark.circle")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Order not found")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
        }
        .navigationTitle("Order Details")
        .onAppear {
            orderViewModel.fetchOrderDetails(orderId: orderId)
        }
        .sheet(isPresented: $showInvoice) {
            if let invoiceUrl = orderViewModel.invoiceUrl,
               let url = URL(string: invoiceUrl) {
                SafariView(url: url)
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
}

struct ProductOrderRow: View {
    let product: OrderProduct
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.productId.label["en"] ?? "Unknown Product")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Text("Quantity: \(product.quantity)")
                    .foregroundColor(.gray)
                Spacer()
                Text("\(String(format: "%.2f", product.price))€")
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 5)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .foregroundColor(.primary)
            Spacer()
        }
        .font(.subheadline)
    }
} 