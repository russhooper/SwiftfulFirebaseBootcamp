//
//  ProductsManager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Russ Hooper on 8/22/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class ProductsManager {
    
    static let shared = ProductsManager()
    private init() { }
    
    private let productsCollection = Firestore.firestore().collection("products")
    
    private func productDocument(productID: String) -> DocumentReference {
        productsCollection.document(productID)
    }
    
    func uploadProduct(product: Product) async throws {
        try productDocument(productID: String(product.id)).setData(from: product, merge: false)
    }
    
    func getProduct(productID: String) async throws -> Product {
        try await productDocument(productID: productID).getDocument(as: Product.self)
    }
    
    /*
     private func getAllProducts() async throws -> [Product] {
     try await productsCollection
     //  .limit(to: 5)
     .getDocuments(as: Product.self) // need to be careful that this isn't getting a zillion results, as we pay by result
     }
     
     private func getAllProductsSortedByPrice(descending: Bool) async throws -> [Product] {
     try await productsCollection
     .order(by: Product.CodingKeys.price.rawValue, descending: descending)
     .getDocuments(as: Product.self)
     }
     
     private func getAllProductsForCategory(category: String) async throws -> [Product] {
     try await productsCollection
     .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
     .getDocuments(as: Product.self)
     }
     
     private func getAllProductsByPriceAndCategory(descending: Bool, category: String) async throws -> [Product] {
     try await productsCollection
     .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
     .order(by: Product.CodingKeys.price.rawValue, descending: descending)
     .getDocuments(as: Product.self)
     }
     */
    
    private func getAllProductsQuery() -> Query {
        productsCollection
    }
    
    private func getAllProductsSortedByPriceQuery(descending: Bool) -> Query {
        productsCollection
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
    }
    
    private func getAllProductsForCategoryQuery(category: String) -> Query {
        productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
    }
    
    private func getAllProductsByPriceAndCategoryQuery(descending: Bool, category: String) -> Query {
        productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
    }
    
    
    func getAllProducts(priceDescending descending: Bool?,
                        forCategory category: String?,
                        count: Int,
                        lastDocument: DocumentSnapshot?)
    async throws -> (
        products: [Product],
        lastDocument: DocumentSnapshot?
    ) {
        
        var query: Query = getAllProductsQuery()
        
        if let descending, let category {
            query = getAllProductsByPriceAndCategoryQuery(descending: descending, category: category)
        } else if let descending {
            query = getAllProductsSortedByPriceQuery(descending: descending)
        } else if let category {
            query = getAllProductsForCategoryQuery(category: category)
        }
        
        return try await query
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Product.self)
        
    }

    
    func getProductsByRating(count: Int, lastRating: Double?) async throws -> ([Product]) {
        try await productsCollection
            .order(by: Product.CodingKeys.rating.rawValue, descending: true)
            .limit(to: count)
            .start(after: [lastRating ?? 999999])
            .getDocuments(as: Product.self)
    }
    
    func getProductsByRating(count: Int, lastDocument: DocumentSnapshot?) async throws -> (
        products: [Product],
        lastDocument: DocumentSnapshot?) {
            
            if let lastDocument {
                return try await productsCollection
                    .order(by: Product.CodingKeys.rating.rawValue, descending: true)
                    .limit(to: count)
                    .start(afterDocument: lastDocument)
                    .getDocumentsWithSnapshot(as: Product.self)
            } else {
                return try await productsCollection
                    .order(by: Product.CodingKeys.rating.rawValue, descending: true)
                    .limit(to: count)
                    .getDocumentsWithSnapshot(as: Product.self)
            }
            
            
            
        }
    
    
    func getAllProductsCount() async throws -> Int {
        try await productsCollection.aggregateCount()
    }
    
}
