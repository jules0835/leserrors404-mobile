import SwiftUI

struct OrderListView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @State private var selectedOrder: Order?
    
    var body: some View {
        List {
            if orderViewModel.isLoading {
                ProgressView()
            } else if let error = orderViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                ForEach(orderViewModel.orders) { order in
                    Button(action: {
                        selectedOrder = order
                    }) {
                        OrderRow(order: order)
                    }
                }
            }
        }
        .navigationTitle("Orders")
        .onAppear {
            orderViewModel.fetchOrders()
        }
        .sheet(item: $selectedOrder) { order in
            NavigationView {
                OrderDetailView(orderId: order.id)
                    .environmentObject(orderViewModel)
            }
        }
    }
}

struct OrderRow: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order #\(order.shortId)")
                .font(.headline)
            
            HStack {
                Text("Status:")
                    .foregroundColor(.gray)
                Text(order.orderStatus)
                    .foregroundColor(order.orderStatus == "PAID" ? .green : .orange)
            }
            
            HStack {
                Text("Total:")
                    .foregroundColor(.gray)
                Text("\(String(format: "%.2f", order.stripe.amountTotal))€")
                    .fontWeight(.semibold)
            }
            
            Text(formatDate(order.createdAt))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
}

struct OrderListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderListView()
                .environmentObject(OrderViewModel())
        }
    }
} 
