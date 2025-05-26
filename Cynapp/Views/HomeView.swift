import SwiftUI


struct ProductsResponse: Codable {
    let products: [Product]
    let total: Int
}


struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image container with rounded corners
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: product.picture)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                    } else if phase.error != nil {
                        Color.gray.opacity(0.2)
                            .frame(height: 180)
                    } else {
                        ProgressView()
                            .frame(height: 180)
                    }
                }
                
                // Subscription badge
                if product.subscription {
                    Text("Subscription")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple)
                        .cornerRadius(6)
                        .padding(8)
                }
            }
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 8) {
                Text(product.label["en"] ?? "Titre indisponible")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(product.description["en"] ?? "Description indisponible")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Price
                HStack {
                    if product.subscription, let monthlyPrice = product.priceMonthly {
                        Text("\(String(format: "%.2f", monthlyPrice))€")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        Text("/month")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(String(format: "%.2f", product.price))€")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

struct InfiniteCarouselView<Content: View, T: Identifiable>: View {
    var items: [T]
    var content: (T) -> Content

    @State private var currentIndex: Int
    private var itemsCount: Int { items.count }
    private var infiniteItems: [T] {
        items + items + items
    }

    init(items: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.items = items
        self.content = content
        _currentIndex = State(initialValue: items.isEmpty ? 0 : items.count)
    }

    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(0..<infiniteItems.count, id: \.self) { index in
                    content(infiniteItems[index])
                        .tag(index)
                        .frame(width: UIScreen.main.bounds.width - 40)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 300)
            .animation(.spring(), value: currentIndex)
            .onChange(of: currentIndex) {newValue in
                guard itemsCount > 0 else { return }
                let lowerBound = itemsCount
                let upperBound = 2 * itemsCount - 1
                if newValue < lowerBound {
                    withAnimation(.none) {
                        currentIndex += itemsCount
                    }
                } else if newValue > upperBound {
                    withAnimation(.none) {
                        currentIndex -= itemsCount
                    }
                }
            }

            HStack(spacing: 8) {
                ForEach(0..<itemsCount, id: \.self) { dot in
                    Circle()
                        .fill((currentIndex % itemsCount) == dot ? Color.white : Color.gray)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 8)
        }
    }
}


struct HomeView: View {
    @Binding var searchText: String
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    var body: some View {
        NavigationView {
            ZStack {
                ProductListView(searchText: $searchText)
            }
        }
        .onAppear {
            if categoryViewModel.categories.isEmpty {
                categoryViewModel.fetchCategories()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(searchText: .constant(""))
            .environmentObject(CategoryViewModel())
    }
}
