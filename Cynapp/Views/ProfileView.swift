import SwiftUI
import SafariServices

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @State private var showLogin = false
    @State private var authToken: String? = nil
    @StateObject private var viewModel = ConnectedProfileViewModel()

    var body: some View {
        ZStack {
            Color("CynaBg")
                .ignoresSafeArea()
            VStack(spacing: 20) {
                if isLoggedIn {
                    ConnectedProfileView()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                        
                        Text("Vous n'êtes pas connecté")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            showLogin = true
                        }) {
                            Text("Se connecter")
                                .font(.headline)
                                .foregroundColor(Color("CynaBg"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 40)
                    }
                }
            }
        }
        .onAppear {
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                isLoggedIn = true
                viewModel.fetchUserProfile()
            } else {
                showLogin = true
            }
        }
        .fullScreenCover(isPresented: $showLogin) {
            SafariView(url: URL(string: "https://b3-cyna-web.vercel.app/en/auth/login?appMobileLogin=true")!)
        }
        .onOpenURL { url in
            print("URL reçue : \(url)")
            if url.scheme == "cynapp", url.host == "auth",
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let token = components.queryItems?.first(where: { $0.name == "authToken" })?.value {
                UserDefaults.standard.set(token, forKey: "authToken")
                isLoggedIn = true
                viewModel.fetchUserProfile()
                showLogin = false
            }
        }
    }
}

struct ConnectedProfileView: View {
    @StateObject private var viewModel = ConnectedProfileViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                if let profile = viewModel.userProfile {
                    // Header avec photo de profil
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.white)
                        
                        Text("\(profile.firstName) \(profile.lastName)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(profile.email)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                    
                    // Informations de contact
                    VStack(alignment: .leading, spacing: 15) {
                        ProfileInfoCard(title: "Contact", icon: "phone.fill") {
                            if let phone = profile.phone {
                                Text(phone)
                                    .foregroundColor(.white)
                            } else {
                                Text("Non renseigné")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        ProfileInfoCard(title: "Company", icon: "building.2.fill") {
                            if let company = profile.company {
                                Text(company)
                                    .foregroundColor(.white)
                            } else {
                                Text("Unknow")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        if let address = profile.address {
                            ProfileInfoCard(title: "Address", icon: "location.fill") {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(address.street)
                                    Text("\(address.zipCode) \(address.city)")
                                }
                                .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchUserProfile()
        }
    }
}

struct ProfileInfoCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

// ViewModel pour récupérer les données utilisateur
class ConnectedProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?
    
    func fetchUserProfile() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            errorMessage = "Token introuvable."
            return
        }
        
        guard let url = URL(string: "\(AppConstants.baseURL)en/api/user/dashboard/profile") else {
            errorMessage = "URL invalide."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    self.errorMessage = "Erreur HTTP : \(httpResponse.statusCode)"
                    return
                }
                guard let data = data else {
                    self.errorMessage = "Aucune donnée reçue."
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let profile = try decoder.decode(UserProfile.self, from: data)
                    self.userProfile = profile
                } catch {
                    self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
