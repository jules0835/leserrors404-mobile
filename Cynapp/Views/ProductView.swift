import SwiftUI
import SafariServices

struct ProductView: View {
    let product: Product
    
    @State private var quantity = 1
    @State private var isAddedToCart = false
    @State private var isAddingToCart = false
    @State private var showLogin = false
    @EnvironmentObject var cartViewModel: CartViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Titre du produit centré
                Text(product.label["en"] ?? "Titre indisponible")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                // Image du produit centrée
                AsyncImage(url: URL(string: product.picture)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.gray
                }
                .frame(height: 200)
                .padding(.horizontal)
                
                Text(product.description["en"] ?? "Description indisponible")
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                HStack {
                    Text("Quantity: ")
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        if quantity > 1 {
                            quantity -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                    }
                    
                    Text("\(quantity)")
                        .font(.title2)
                        .frame(width: 40, alignment: .center)
                    
                    Button(action: {
                        quantity += 1
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                
                if product.subscription {
                    Text("Price: \(String(format: "%.2f", product.priceMonthly ?? 0.0))€")
                        .font(.title)
                        .padding(.vertical)
                }
                else
                {
                    Text("Price: \(String(format: "%.2f", product.price ?? 0.0))€")
                        .font(.title)
                        .padding(.vertical)
                }

                Button(action: {
                    if UserDefaults.standard.string(forKey: "authToken") != nil {
                        if !isAddingToCart {
                            addToCart(productId: product.id)
                        }
                    } else {
                        showLogin = true
                    }
                }) {
                    HStack {
                        if isAddingToCart {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "cart.fill")
                            Text("Add to cart")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isAddingToCart)
                .padding(.horizontal)
                
                if isAddedToCart {
                    Text("Produit ajouté au panier !")
                        .foregroundColor(.green)
                        .padding()
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, 8)
        .fullScreenCover(isPresented: $showLogin) {
            SafariView(url: URL(string: "https://b3-cyna-web.vercel.app/en/auth/login?appMobileLogin=true")!)
        }
        .onOpenURL { url in
            if url.scheme == "cynapp", url.host == "auth",
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let token = components.queryItems?.first(where: { $0.name == "authToken" })?.value {
                UserDefaults.standard.set(token, forKey: "authToken")
                showLogin = false
            }
        }
    }

    func addToCart(productId: String) {
        // Empêcher les appels multiples
        guard !isAddingToCart else { return }
        
        // Récupérer l'ID du panier et le token depuis UserDefaults
        guard let cartId = UserDefaults.standard.string(forKey: "cartId"),
              let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("Aucun ID de panier ou token trouvé.")
            return
        }

        // Mettre à jour l'état de chargement
        isAddingToCart = true

        // Construire l'URL avec les paramètres
        let urlString = "\(AppConstants.baseURL)en/api/shop/cart/\(cartId)?action=add&quantity=\(quantity)&productId=\(productId)"
        print("URL construite : \(urlString)")

        guard let url = URL(string: urlString) else {
            isAddingToCart = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Appeler l'API pour ajouter au panier
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Réinitialiser l'état de chargement
                isAddingToCart = false
                
                if let error = error {
                    print("Erreur lors de l'ajout au panier: \(error)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // Mettre à jour l'état uniquement si l'API a répondu positivement
                        isAddedToCart = true
                        // Rafraîchir le panier pour s'assurer que tout est synchronisé
                        cartViewModel.refreshCart()
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
}
