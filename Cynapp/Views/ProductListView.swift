import SwiftUI

struct ProductListView: View {
    @Binding var searchText: String
    @StateObject private var viewModel = ProductListViewModel()
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    var groupedProducts: [(categorie: String, products: [Product])] {
        let groups = Dictionary(grouping: viewModel.products, by: { $0.categorie })
        return groups.map { (categorie: $0.key, products: $0.value) }
            .sorted { $0.categorie < $1.categorie }
    }

    func categoryLabel(for id: String) -> String {
        guard let cat = categoryViewModel.categories[id] else {
            return "Catégorie"
        }
        return cat.label["en"] ?? cat.label["fr"] ?? "Catégorie"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.products.isEmpty || categoryViewModel.categories.isEmpty {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    let enumeratedGroups = Array(groupedProducts.enumerated())
                    ForEach(enumeratedGroups, id: \.element.categorie) { index, group in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(categoryLabel(for: group.categorie))
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.top, index == 0 ? 32 : 8)

                            InfiniteCarouselView(items: group.products) { product in
                                NavigationLink(destination: ProductView(product: product)) {
                                    ProductCard(product: product)
                                }
                            }
                            .id(searchText)
                        }
                    }
                }
            }
        }
        .background(Color("CynaBg"))
        .id(searchText)
        .onAppear {
            viewModel.fetchProducts(searchQuery: searchText)
        }
        .onChange(of: searchText) { newValue in
            viewModel.products = []
            viewModel.fetchProducts(searchQuery: newValue)
        }
    }
}
