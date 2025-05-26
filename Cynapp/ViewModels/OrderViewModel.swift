import Foundation
import Combine

class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var selectedOrder: Order?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var invoiceUrl: String? = nil

    private var cancellables = Set<AnyCancellable>()

    func fetchOrders() {
        print("Starting to fetch orders...")
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("No auth token found")
            self.errorMessage = "Authentication required"
            return
        }

        guard let url = URL(string: "\(AppConstants.baseURL)en/api/user/dashboard/business/orders") else {
            print("Invalid URL")
            self.errorMessage = "URL invalide."
            return
        }

        isLoading = true
        errorMessage = nil

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                // Log the raw response data
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(jsonString)")
                }
                return data
            }
            .decode(type: OrdersResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    print("Error fetching orders: \(error)")
                    self?.errorMessage = "Erreur lors du chargement des commandes: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] response in
                print("Successfully decoded \(response.orders.count) orders")
                self?.orders = response.orders
            })
            .store(in: &cancellables)
    }

    func fetchOrderDetails(orderId: String) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            self.errorMessage = "Authentication required"
            return
        }

        isLoading = true
        errorMessage = nil

        let url = URL(string: "\(AppConstants.baseURL)en/api/user/dashboard/business/orders/\(orderId)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                // Log the raw response data
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw Order Details Response: \(jsonString)")
                }
                return data
            }
            .decode(type: Order.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    print("Error fetching order details: \(error)")
                    self?.errorMessage = "Erreur lors du chargement des détails de la commande: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] order in
                print("Successfully decoded order details")
                self?.selectedOrder = order
            })
            .store(in: &cancellables)
    }

    func fetchInvoiceUrl(invoiceId: String) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            self.errorMessage = "Authentication required"
            return
        }

        isLoading = true
        errorMessage = nil

        let url = URL(string: "\(AppConstants.baseURL)en/api/user/dashboard/business/invoices/\(invoiceId)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw Invoice Response: \(jsonString)")
                }
                return data
            }
            .decode(type: InvoiceResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    print("Error fetching invoice: \(error)")
                    self?.errorMessage = "Erreur lors du chargement de la facture: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] response in
                print("Successfully decoded invoice URL")
                self?.invoiceUrl = response.invoiceUrl
            })
            .store(in: &cancellables)
    }
}

struct InvoiceResponse: Codable {
    let invoiceUrl: String
} 
