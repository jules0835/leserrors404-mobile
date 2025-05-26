import SwiftUI
import SafariServices

struct MainView: View {
    @State private var selectedTab: Int = 0
    @State private var isLoggedIn: Bool = false
    @State private var searchText: String = ""
    @State private var showMenu: Bool = false
    @State private var showOrders = false
    @State private var showSubscriptions = false
    @State private var showSecurity = false
    @State private var showSupport = false
    @EnvironmentObject var cartViewModel: CartViewModel
    @StateObject private var orderViewModel = OrderViewModel()
    
    init() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(named: "CynaBg")
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
    
    var body: some View {
        NavigationView  {
            ZStack {
                TabView(selection: $selectedTab) {
                    HomeView(searchText: $searchText)
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                        .tag(0)
                    
                    ProfileView(isLoggedIn: $isLoggedIn)
                        .tabItem {
                            Image(systemName: "person.crop.circle.fill")
                            Text("Profile")
                        }
                        .tag(1)
                }
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 16) {
                        Button(action: {
                            withAnimation {
                                showMenu.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                        }
                        .frame(width: 32, height: 32)
                        
                        TextField("Search...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(height: 40)
                            .frame(minWidth: 200, maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CartDetailView()) {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("\(cartViewModel.items.reduce(0) { $0 + $1.quantity })")
                        }
                    }
                }
            }
            .overlay(
                ZStack(alignment: .top) {
                    if showMenu {
                        Color.black.opacity(0.001)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    showMenu = false
                                }
                            }
                        VStack(alignment: .leading, spacing: 0) {
                            if selectedTab == 1 {
                                if isLoggedIn {
                                    MenuButton(title: "Log out") {
                                        isLoggedIn = false
                                        UserDefaults.standard.removeObject(forKey: "authToken")
                                        withAnimation {
                                            showMenu = false
                                        }
                                    }
                                    MenuButton(title: "Orders") {
                                        showOrders = true
                                        withAnimation { showMenu = false }
                                    }
                                    MenuButton(title: "Subscription") {
                                        showSubscriptions = true
                                        withAnimation { showMenu = false }
                                    }
                                    //MenuButton(title: "Payments") {
                                     //   withAnimation { showMenu = false }
                                    //}
                                    MenuButton(title: "Security") {
                                        showSecurity = true
                                        withAnimation { showMenu = false }
                                    }
                                }
                            } else {
                                //MenuButton(title: "Filter") {
                                //    withAnimation { showMenu = false }
                                //}
                            }
                            
                            MenuButton(title: "Support") {
                                showSupport = true
                                withAnimation { showMenu = false }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal, 16)
                        .transition(.move(edge: .top))
                    }
                }
            )
            .sheet(isPresented: $showOrders) {
                NavigationView {
                    OrderListView()
                        .environmentObject(orderViewModel)
                }
                .environmentObject(orderViewModel)
            }
            .sheet(isPresented: $showSubscriptions) {
                SubscriptionListView()
            }
            .sheet(isPresented: $showSecurity) {
                NavigationView {
                    SecurityView()
                }
            }
            .sheet(isPresented: $showSupport) {
                WebView(url: URL(string: "https://b3-cyna-web.vercel.app/en/contact?isAppMobile=true")!)
            }
        }
        .environmentObject(orderViewModel)
        .onAppear {
            loadCart()
        }
    }
    
    func loadCart() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("Pas de token disponible.")
            return
        }

        if let savedCartData = UserDefaults.standard.data(forKey: "cart") {
            do {
                let savedCart = try JSONDecoder().decode(CartResponse.self, from: savedCartData)
                UserDefaults.standard.set(savedCart.id, forKey: "cartId")

                DispatchQueue.main.async {
                    cartViewModel.items = savedCart.products.map {
                        CartItem(product: $0.product, quantity: $0.quantity)
                    }
                }
            } catch {
                print("Erreur de décodage du panier local : \(error)")
            }
        }

        let urlString = "\(AppConstants.baseURL)en/api/shop/cart"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur API lors du chargement du panier: \(error)")
                return
            }

            guard let data = data else {
                print("Pas de données reçues de l'API")
                return
            }

            do {
                let cartResponse = try JSONDecoder().decode(CartResponse.self, from: data)

                UserDefaults.standard.set(data, forKey: "cart")
                UserDefaults.standard.set(cartResponse.id, forKey: "cartId")

                DispatchQueue.main.async {
                    cartViewModel.items = cartResponse.products.map {
                        CartItem(product: $0.product, quantity: $0.quantity)
                    }
                }
            } catch {
                print("Erreur de décodage de la réponse API: \(error)")
            }
        }.resume()
    }
}


struct MenuButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.black)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        Divider()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(CartViewModel())
            .environmentObject(OrderViewModel())
    }
}
