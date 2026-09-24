//
//  CustomTabBar.swift
//  English Words
//
//  Created by Егор Халиков on 23.09.2026.
//

import SwiftUI

struct CustomTabBar: View {
    let tabs: [TabItem]
    @Binding var selectedTab: TabItem
    
    @Namespace private var selectionNamespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                tabButton(tab)
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Color.cardBackground)
                .shadow(color: Color.shadowColor, radius: 10, x: 0, y: 4)
        )
        .overlay(
            Capsule()
                .stroke(Color.stroke.opacity(0.5), lineWidth: 1)
        )
    }
    
    private func tabButton(_ tab: TabItem) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 16, weight: .semibold))
                
                if selectedTab == tab {
                    Text(tab.title)
                        .font(.system(size: 14, weight: .semibold))
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .foregroundColor(selectedTab == tab ? .white : Color.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    if selectedTab == tab {
                        Capsule()
                            .fill(Color.accent)
                            .matchedGeometryEffect(id: "selection", in: selectionNamespace)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}
