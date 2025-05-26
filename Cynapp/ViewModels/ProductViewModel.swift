//
//  ProductViewModel.swift
//  Cynapp
//
//  Created by Draskeer on 10/04/2025.
//

import SwiftUI

class ProductViewModel: ObservableObject {
    @Published var product: Product
    @Published var quantity: Int
    @Published var isAddedToCart: Bool
    
    init(product: Product) {
        self.product = product
        self.quantity = 1
        self.isAddedToCart = false
    }
    
    func increaseQuantity() {
        quantity += 1
    }
    
    func decreaseQuantity() {
        if quantity > 1 {
            quantity -= 1
        }
    }
    
    func toggleCartStatus() {
        isAddedToCart.toggle()
        // Add or remove from cart logic can be added here
    }
}
