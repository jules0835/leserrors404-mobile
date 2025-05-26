import SwiftUI
import SafariServices

struct CartDetailView: View {
    @EnvironmentObject var cartViewModel: CartViewModel

    @State private var safariURL: SafariURL?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoadingCheckout = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(cartViewModel.items) { item in
                    CartItemCard(item: item)
                }

                if !cartViewModel.items.isEmpty {
                    VStack(spacing: 12) {
                        Text("Total : \(String(format: "%.2f", cartViewModel.totalPrice())) €")
                            .font(.headline)

                        if isLoadingCheckout {
                            ProgressView("Paiment creation...")
                        } else {
                            Button(action: {
                                initiateCheckout()
                            }) {
                                Text("Proceed to paiement")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 16) {
                        ZStack {
                            Image(systemName: "cart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 140)
                                .foregroundColor(Color.white.opacity(0.18))
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.red)
                                .background(Color.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .offset(y: -60)
                        }
                        Text("Your cart is empty")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Text("It's time to start shopping !")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 350)
                    .padding(.top, 40)
                }
            }
            .padding()
        }
        .navigationTitle("Your Cart")
        .background(Color("CynaBg"))
        .onOpenURL { url in
            handlePaymentRedirect(url: url)
        }
        .sheet(item: $safariURL) { safari in
            SafariView(url: safari.url)
        }
        .alert("Paiement", isPresented: $showAlert, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(alertMessage)
        })
    }

    func initiateCheckout() {
        guard let rawToken = UserDefaults.standard.string(forKey: "authToken") else {
            alertMessage = "You are not connected."
            showAlert = true
            return
        }

        guard let url = URL(string: "\(AppConstants.baseURL)en/api/shop/checkout?appMobileCheckout=true") else {
            alertMessage = "Paiement URL invalid."
            showAlert = true
            return
        }

        isLoadingCheckout = true

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(rawToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [:])

        URLSession.shared.dataTask(with: request) { data, response, error in
            isLoadingCheckout = false

            if let error = error {
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }

            guard let data = data else {
                showError(message: "No data received.")
                return
            }

            if httpResponse.statusCode == 200 {
                do {
                    let result = try JSONDecoder().decode(CheckoutResponse.self, from: data)
                    if result.canCheckout {
                        openSafariCheckout(with: result.url)
                    } else {
                        showError(message: "Unable to preceed further")
                    }
                } catch {
                    showError(message: "Error while decoding")
                }
            } else {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []),
                   let dict = json as? [String: Any],
                   let message = dict["message"] as? String {
                    showError(message: message)
                } else {
                    showError(message: "Error : code \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }

    func openSafariCheckout(with urlString: String) {
        if let url = URL(string: urlString) {
            safariURL = SafariURL(url: url)
        }
    }

    func handlePaymentRedirect(url: URL) {
        guard url.scheme == "cynapp", url.host == "checkout" else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        if let success = queryItems.first(where: { $0.name == "success" })?.value, success == "true" {
            let orderId = queryItems.first(where: { $0.name == "orderId" })?.value ?? "-"
            alertMessage = "✅ Successfully paid !\nCommand Nb°: \(orderId)"

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                cartViewModel.items = []
                cartViewModel.refreshCart()
            }

        } else if let cancelled = queryItems.first(where: { $0.name == "userCancel" })?.value, cancelled == "true" {
            alertMessage = "⚠️ Paiment canceled."
        } else {
            alertMessage = "❌ Paiment failed."
        }

        showAlert = true
    }

    func showError(message: String) {
        DispatchQueue.main.async {
            alertMessage = message
            showAlert = true
        }
    }

    struct CheckoutResponse: Decodable {
        let url: String
        let canCheckout: Bool
    }

    struct SafariURL: Identifiable {
        let id = UUID()
        let url: URL
    }
}

struct CartItemCard: View {
    var item: CartItem
    @EnvironmentObject var cartViewModel: CartViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: URL(string: item.product.picture)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.gray
                }
            }
            .frame(width: 100, height: 100)
            .cornerRadius(12)
            .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(item.product.label["en"] ?? "Produit")
                    .font(.headline)

                HStack(spacing: 6) {
                    Image(systemName: "cart")
                    Text(item.product.subscription ? "Subscription" : "one-time")
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                }
                Text("\(item.product.price * Double(item.quantity), specifier: "%.2f") €")
                    .font(.title3)
                    .fontWeight(.bold)

                Text("\(item.product.price, specifier: "%.0f") € × \(item.quantity)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    Button(action: {
                        if item.quantity > 1 {
                            cartViewModel.addItemToCart(product: item.product, quantity: -1)
                        }
                    }) {
                        if cartViewModel.updatingItemId == item.product.id {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 24, height: 24)
                        } else {
                            Image(systemName: "minus")
                                .frame(width: 24, height: 24)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    .disabled(cartViewModel.updatingItemId != nil)

                    Text("\(item.quantity)")
                        .frame(width: 24)

                    Button(action: {
                        cartViewModel.addItemToCart(product: item.product, quantity: 1)
                    }) {
                        if cartViewModel.updatingItemId == item.product.id {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 24, height: 24)
                        } else {
                            Image(systemName: "plus")
                                .frame(width: 24, height: 24)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    .disabled(cartViewModel.updatingItemId != nil)
                }
            }

            Spacer()

            Button(action: {
                cartViewModel.removeItemFromCart(item: item)
            }) {
                if cartViewModel.updatingItemId == item.product.id {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .disabled(cartViewModel.updatingItemId != nil)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
