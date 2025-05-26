//
//  CategoryViewModel.swift
//  Cynapp
//
//  Created by Draskeer on 10/04/2025.
//

import Foundation

class CategoryViewModel: ObservableObject {
    @Published var categories: [String: Category] = [:]

    func fetchCategories() {
        guard let url = URL(string: "https://b3-cyna-web.vercel.app/en/api/shop/categories") else {
            print("❌ URL invalide")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Erreur de chargement des catégories : \(error)")
                return
            }

            guard let data = data else {
                print("❌ Aucune donnée reçue")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(CategoryResponse.self, from: data)
                DispatchQueue.main.async {
                    self.categories = Dictionary(uniqueKeysWithValues: decoded.categories.map { ($0.id, $0) })
                }
            } catch {
                print("❌ Erreur de décodage des catégories : \(error)")
            }
        }.resume()
    }
}

