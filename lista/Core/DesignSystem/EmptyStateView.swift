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
        }
        .padding(.horizontal, 32)
        .accessibilityElement(children: .combine)
    }
}

