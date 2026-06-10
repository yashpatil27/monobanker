//
//  TipJarStore.swift
//  MonoBanker
//
//  StoreKit 2-backed model for the three consumable tip products.
//  Set up the matching products in App Store Connect (or a StoreKit
//  Configuration file for local testing) with these product IDs.
//

import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class TipJarStore {
    /// Product identifiers — must match what you create in App Store Connect.
    static let productIDs: [String] = [
        "com.monobanker.tip.small.v2",
        "com.monobanker.tip.medium.v2",
        "com.monobanker.tip.large.v2"
    ]

    /// Loaded products, sorted ascending by price.
    var products: [Product] = []

    /// True while products are being fetched from the App Store.
    var isLoading = false

    /// Last error from product loading or a purchase attempt, if any.
    var errorMessage: String?

    /// Flips to true after a successful tip purchase, drives the UI's thank-you state.
    var didTipRecently = false

    // MARK: - Loading

    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let loaded = try await Product.products(for: TipJarStore.productIDs)
            products = loaded.sorted { $0.price < $1.price }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Purchasing

    /// Returns true if the tip was actually completed.
    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        errorMessage = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    // Consumables: finish the transaction immediately so it doesn't reappear.
                    await transaction.finish()
                    didTipRecently = true
                    return true
                } else {
                    errorMessage = "Couldn't verify the purchase."
                    return false
                }
            case .userCancelled:
                return false
            case .pending:
                // Ask-to-buy / SCA flow — Apple will deliver via Transaction.updates later.
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func acknowledgeThanks() {
        didTipRecently = false
    }
}
