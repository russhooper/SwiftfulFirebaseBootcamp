//
//  FavoritesView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Russ Hooper on 8/31/24.
//

import SwiftUI

struct FavoritesView: View {
    
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.userFavoriteProducts, id: \.id.self) { item in
                ProductCellViewBuilder(productID: String(item.productID))
                    .contextMenu(ContextMenu(menuItems: {
                        Button("Remove from favorites") {
                            viewModel.removeFromFavorites(favoriteProductID: item.id)
                        }
                    }))
            }
        }
        .navigationTitle("Favorites")
        .onFirstAppear {
            viewModel.addListenerForFavorites()
        }
        
        
    }
}




#Preview {
    NavigationStack {
        FavoritesView()
    }
}
