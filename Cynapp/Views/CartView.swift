//
//  Cart.swift
//  Cynapp
//
//  Created by Draskeer on 10/04/2025.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    
    var body: some View {
        VStack {
            Text("Your Cart")
                .font(.title)
                .padding()
            
            List {
                ForEach(cartViewModel.items) { item in
                    HStack {
                        Text(item.product.label["en"] ?? "Unnamed Product")
                        Spacer()
                        Text("\(item.quantity) x $\(item.product.price, specifier: "%.2f")")
                    }
                }
            }
            
            HStack {
                Text("Total: $\(cartViewModel.totalPrice(), specifier: "%.2f")")
                    .font(.headline)
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Cart")
        .padding()
    }
}
