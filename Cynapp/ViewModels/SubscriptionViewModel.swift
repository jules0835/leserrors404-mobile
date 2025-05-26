import Foundation
import Combine

class SubscriptionViewModel: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchSubscriptions() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            self.errorMessage = "Vous devez être connecté pour voir vos abonnements."
            return
        }
        
        guard let url = URL(string: "\(AppConstants.baseURL)en/api/user/dashboard/business/subscriptions?page=0&limit=100") else {
            self.errorMessage = "URL invalide."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(jsonString)")
                }
                return data
            }
            .decode(type: SubscriptionsResponse.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    print("Decoding error: \(error)")
                    self?.errorMessage = "Erreur lors du chargement des abonnements: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] response in
                print("Successfully decoded subscriptions: \(response.subscriptions.count)")
                self?.subscriptions = response.subscriptions
            })
            .store(in: &cancellables)
    }
    
    func fetchSubscriptionDetails(id: String) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            self.errorMessage = "Vous devez être connecté pour voir les détails de l'abonnement."
            return
        }
        
        guard let url = URL(string: "\(AppConstants.baseURL)en/api/user/dashboard/business/subscriptions/\(id)") else {
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
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(jsonString)")
                }
                return data
            }
            .decode(type: Subscription.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    print("Decoding error: \(error)")
                    self?.errorMessage = "Erreur lors du chargement des détails de l'abonnement: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] subscription in
                print("Successfully decoded subscription details")
                if let index = self?.subscriptions.firstIndex(where: { $0.id == subscription.id }) {
                    self?.subscriptions[index] = subscription
                }
            })
            .store(in: &cancellables)
    }
} 