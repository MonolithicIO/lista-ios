//
//  EmptyStateView.swift
//  lista
//
//  Created by Lucca Beurmann on 29/01/26.
//

import Foundation
import SwiftUI

struct EmptyStateView: View {

    let title: String
    let description: String
    let iconName: String
    let actionTitle: String?
    let onAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 44, weight: .regular))
                .foregroundStyle(AppColors.mutedForeground)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppColors.foreground)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.mutedForeground)
                    .multilineTextAlignment(.center)
            }
            if let actionTitle, let onAction {
                Button(action: onAction) {
                    Text(actionTitle)
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal, 32)
        .accessibilityElement(children: .combine)
    }
}
