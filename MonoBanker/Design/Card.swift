//
//  Card.swift
//  MonoBanker
//

import SwiftUI

struct Card<Content: View>: View {
    let padding: Bool
    let cornerRadius: CGFloat
    let content: Content

    init(
        padding: Bool = true,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        Group {
            if padding {
                content.padding(DesignSystem.Spacing.lg)
            } else {
                content
            }
        }
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.gray.opacity(DesignSystem.Opacity.subtle))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.gray.opacity(DesignSystem.Opacity.medium),
                                lineWidth: DesignSystem.BorderWidth.thin)
                )
        )
    }
}

#Preview {
    Card {
        Text("Card preview").foregroundColor(.white)
    }
    .padding()
    .background(Color.black)
}
