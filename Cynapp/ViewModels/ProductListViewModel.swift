//
//  ProductListViewModel.swift
//  Cynapp
//
//  Created by Draskeer on 10/04/2025.
//
import SwiftUI

class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []

    func fetchProducts(searchQuery: String? = nil) {
        let query = searchQuery ?? ""
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://b3-cyna-web.vercel.app/en/api/shop/products?limit=100&q=\(encodedQuery)&page=0") else {
            print("URL invalide")
            return
        }

        print("Fetching: \(url)")
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Erreur: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("Pas de données")
                return
            }
            DispatchQueue.main.async {
                do {
                    let decoded = try JSONDecoder().decode(ProductsResponse.self, from: data)
                    self.products = decoded.products
                } catch {
                    print("Erreur de décodage: \(error)")
                }
            }
        }.resume()
    }
}
