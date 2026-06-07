//
//  IconContainer.swift
//  MonoBanker
//

import SwiftUI

struct IconContainer: View {
    let systemName: String
    let tint: Color
    let backgroundColor: Color
    let size: CGFloat
    let iconSize: CGFloat
    let cornerRadius: CGFloat

    init(
        systemName: String,
        tint: Color = .white,
        backgroundColor: Color? = nil,
        size: CGFloat = 36,
        iconSize: CGFloat = 16,
        cornerRadius: CGFloat = 10
    ) {
        self.systemName = systemName
        self.tint = tint
        self.backgroundColor = backgroundColor ?? Color.gray.opacity(0.2)
        self.size = size
        self.iconSize = iconSize
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .frame(width: size, height: size)

            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(tint)
        }
    }
}
