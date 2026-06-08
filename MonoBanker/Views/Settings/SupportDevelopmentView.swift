//
//  SupportDevelopmentView.swift
//  MonoBanker
//

import SwiftUI
import StoreKit

struct SupportDevelopmentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = TipJarStore()

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        intro

                        if store.didTipRecently {
                            thanksCard
                        } else {
                            tipCards
                        }

                        if let error = store.errorMessage {
                            Text(error)
                                .font(.system(size: 12))
                                .foregroundColor(.error)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        footerNote
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.vertical, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xxxl)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task { await store.loadProducts() }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                HapticManager.shared.lightImpact()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.brandPrimary)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }

            Spacer()

            Text("Support Development")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)

            Spacer()

            Spacer().frame(width: 44)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, 2)
        .padding(.bottom, DesignSystem.Spacing.md)
    }

    // MARK: - Intro

    private var intro: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.18))
                    .frame(width: 72, height: 72)
                Image(systemName: "heart.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.brandPrimary)
            }

            Text("Enjoying MonoBanker?")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)

            Text("If this app has made game night smoother, you can leave a tip to support its development. It's completely optional and there's nothing locked behind it.")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .padding(.top, DesignSystem.Spacing.md)
    }

    // MARK: - Tip cards

    @ViewBuilder
    private var tipCards: some View {
        if store.isLoading {
            ProgressView()
                .tint(.brandPrimary)
                .padding(.vertical, DesignSystem.Spacing.xxl)
        } else if store.products.isEmpty {
            unavailableState
        } else {
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(Array(store.products.enumerated()), id: \.element.id) { index, product in
                    TipCard(
                        product: product,
                        icon: TipCard.icon(for: index),
                        onTap: { Task { await tap(product) } }
                    )
                }
            }
        }
    }

    private var unavailableState: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "exclamationmark.bubble")
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(.textSecondary)
            Text("Tipping isn't available right now.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textSecondary)
            Text("Please try again later.")
                .font(.system(size: 12))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxl)
    }

    // MARK: - Thanks state

    private var thanksCard: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.18))
                    .frame(width: 64, height: 64)
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.brandPrimary)
            }

            Text("Thank you!")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.textPrimary)

            Text("Your tip really helps. It means a lot.")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                HapticManager.shared.lightImpact()
                store.acknowledgeThanks()
            } label: {
                Text("Show tips again")
            }
            .buttonStyle(BrandButtonStyle())
            .padding(.top, DesignSystem.Spacing.sm)
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(Color.brandPrimary.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .stroke(Color.brandPrimary.opacity(0.35), lineWidth: 1)
                )
        )
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Footer note

    private var footerNote: some View {
        Text("Tips are processed through Apple's secure payment system. Pricing and currency are shown in your local format.")
            .font(.system(size: 11))
            .foregroundColor(.textSecondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.md)
    }

    // MARK: - Actions

    private func tap(_ product: Product) async {
        HapticManager.shared.lightImpact()
        let ok = await store.purchase(product)
        if ok {
            HapticManager.shared.success()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                // store.didTipRecently is already set by the store; trigger UI refresh via animation.
            }
        }
    }
}

// MARK: - Tip card

private struct TipCard: View {
    let product: Product
    let icon: String
    let onTap: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.md) {
                IconContainer(
                    systemName: icon,
                    tint: .brandPrimary,
                    backgroundColor: Color.brandPrimary.opacity(0.18)
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName.isEmpty ? defaultName : product.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textPrimary)
                    if !product.description.isEmpty {
                        Text(product.description)
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.brandPrimary)
                    .monospacedDigit()
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(Color.gray.opacity(pressed ? DesignSystem.Opacity.light : DesignSystem.Opacity.subtle))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(Color.gray.opacity(DesignSystem.Opacity.medium), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }

    private var defaultName: String {
        switch icon {
        case "cup.and.saucer.fill": return "Small Tip"
        case "gift.fill": return "Medium Tip"
        case "heart.fill": return "Big Tip"
        default: return "Tip"
        }
    }

    /// Maps a sorted tip index to a representative icon.
    static func icon(for index: Int) -> String {
        switch index {
        case 0: return "cup.and.saucer.fill"
        case 1: return "gift.fill"
        default: return "heart.fill"
        }
    }
}
