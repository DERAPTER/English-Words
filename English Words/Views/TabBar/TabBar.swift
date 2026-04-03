//
//  TabBar.swift
//  English Words
//
//  Created by Егор Халиков on 02.04.2026.
//

import SwiftUI

struct CustomTabBar: View {
    let tabs: [TabItem]
    @Binding var selectedTab: TabItem
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    withAnimation(.spring()) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22, weight: selectedTab == tab ? .bold : .regular))
                        Text(tab.localizedTitle)
                            .font(.captionCustom)
                    }
                    .foregroundColor(selectedTab == tab ? themeManager.colors.accent : themeManager.colors.textSecondary)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: themeManager.colors.shadowColor, radius: 10, x: 0, y: 5)
        )
    }
}
