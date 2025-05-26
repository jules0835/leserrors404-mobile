import SwiftUI

class CartViewModel: ObservableObject {
    @Published var items: [CartItem]
    @Published var isLoading: Bool = false
    @Published var updatingItemId: String? = nil
    
    init(items: [CartItem] = []) {
        self.items = items
    }
    
    func addItemToCart(product: Product, quantity: Int) {
        guard updatingItemId != product.id else { return }
        
        guard let cartId = UserDefaults.standard.string(forKey: "cartId"),
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("Aucun ID de panier ou token trouvé.")
            return
        }

        let currentQuantity = items.first(where: { $0.product.id == product.id })?.quantity ?? 0
        let finalQuantity = max(0, currentQuantity + quantity)

        if finalQuantity == 0 {
            if let itemToRemove = items.first(where: { $0.product.id == product.id }) {
                removeItemFromCart(item: itemToRemove)
            }
            return
        }

        updatingItemId = product.id

        let action = quantity > 0 ? "add" : "update"
        let quantityToSend = quantity > 0 ? 1 : finalQuantity

        let urlString = "\(AppConstants.baseURL)en/api/shop/cart/\(cartId)?action=\(action)&quantity=\(quantityToSend)&productId=\(product.id)"
        print("URL construite : \(urlString)")

        guard let url = URL(string: urlString) else {
            updatingItemId = nil
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.updatingItemId = nil
                
                if let error = error {
                    print("Erreur lors de la mise à jour du panier: \(error)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        self.refreshCart()
                    } else {
                        print("Erreur dans la réponse de l'API: Code \(httpResponse.statusCode)")
                        if let data = data, let responseString = String(data: data, encoding: .utf8) {
                            print("Réponse de l'API: \(responseString)")
                        }
                    }
                }
            }
        }.resume()
    }
    
    func removeItemFromCart(item: CartItem) {
        guard updatingItemId != item.product.id else { return }
        
        guard let cartId = UserDefaults.standard.string(forKey: "cartId"),
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("Aucun ID de panier ou token trouvé.")
            return
        }

        updatingItemId = item.product.id

        let urlString = "\(AppConstants.baseURL)en/api/shop/cart/\(cartId)?action=remove&productId=\(item.product.id)"
        print("URL de suppression construite : \(urlString)")

        guard let url = URL(string: urlString) else {
            updatingItemId = nil
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.updatingItemId = nil
                
                if let error = error {
                    print("Erreur lors de la suppression du panier: \(error)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        self.refreshCart()
                    } else {
                        print("Erreur dans la réponse de l'API: Code \(httpResponse.statusCode)")
                        if let data = data, let responseString = String(data: data, encoding: .utf8) {
                            print("Réponse de l'API: \(responseString)")
                        }
                    }
                }
            }
        }.resume()
    }
    
    func totalPrice() -> Double {
        return items.reduce(0) { $0 + $1.totalPrice() }
    }

    func refreshCart() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ Pas de token pour recharger le panier.")
            return
        }

        guard let url = URL(string: "\(AppConstants.baseURL)en/api/shop/cart") else {
            print("❌ URL invalide pour l'API du panier.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Erreur réseau lors du refresh du panier : \(error)")
                return
            }

            guard let data = data else {
                print("❌ Pas de données panier.")
                return
            }

            do {
                let cartResponse = try JSONDecoder().decode(CartResponse.self, from: data)
                DispatchQueue.main.async {
                    self.items = cartResponse.products.map {
                        CartItem(product: $0.product, quantity: $0.quantity)
                    }
                    print("✅ Panier rechargé depuis le serveur.")
                }
            } catch {
                print("❌ Erreur décodage CartResponse : \(error)")
            }
        }.resume()
    }
}

struct CartItem: Identifiable {
    var id = UUID()
    var product: Product
    var quantity: Int
    
    func totalPrice() -> Double {
        return product.price * Double(quantity)
    }
}
