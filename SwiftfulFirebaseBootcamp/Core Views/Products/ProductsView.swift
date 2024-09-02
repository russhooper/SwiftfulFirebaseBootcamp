//
//  ProductsView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Russ Hooper on 8/22/24.
//

import SwiftUI

struct ProductsView: View {
    
    @StateObject private var viewModel = ProductsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.products) { product in
                ProductCellView(product: product)
                    .contextMenu(ContextMenu(menuItems: {
                        Button("Add to favorites") {
                            viewModel.addUserFavoriteProduct(productID: product.id)
                        }
                    }))
                
                if product == viewModel.products.last { // would probably want to call at last-5 objects to have more time to load
                    ProgressView()
                        .onAppear {
                            print("fetching new products")
                            viewModel.getProducts()
                        }
                }
            }
            
            
            /*
             Button("Fetch more objects") {
             viewModel.getProductsByRating()
             }
             */
            
            
        }
        .navigationTitle("Products")
        .toolbar(content: {
            
            ToolbarItem(placement: .navigationBarLeading) {
                Menu("Sort: \(viewModel.selectedSort?.rawValue ?? "NONE")") {
                    ForEach(ProductsViewModel.SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.sortSelected(option: option)
                            }
                            
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Category: \(viewModel.selectedCategory?.rawValue ?? "NONE")") {
                    ForEach(ProductsViewModel.CategoryOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.categorySelected(option: option)
                            }
                            
                        }
                    }
                }
            }
        })
        .onAppear {
            viewModel.getProducts()
        }
        
    }
}

#Preview {
    ProductsView()
}
