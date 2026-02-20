//
//  ItemStatusBadge.swift
//  lista
//

import Foundation
import SwiftUI

struct ItemStatusBadge: View {
    let isItemCompleted: Bool

    var body: some View {
        Label {
            Text(LocalizedStringKey(title))
        } icon: {
            Image(systemName: systemImage)
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(foregroundStyle)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(backgroundStyle)
        )
        .accessibilityLabel(accessibilityLabel)
    }

    private var title: String {
        if isItemCompleted {
            String(localized: "status.completed")
        } else {
            String(localized: "status.active")
        }
    }

    private var systemImage: String {
        if isItemCompleted {
            return "checkmark.circle.fill"
        } else {
            return "circle"
        }
    }

    private var foregroundStyle: Color {
        if isItemCompleted {
            return AppColors.green
        } else {
            return .secondary
        }
    }

    private var backgroundStyle: Color {
        if  isItemCompleted {
            return AppColors.green.opacity(0.15)
        } else {
            return AppColors.blue.opacity(0.15)
        }
    }

    private var accessibilityLabel: String {
        "Item status: \(title)"
    }
}

#Preview("Active Item in Active List") {
    HStack {
        ItemStatusBadge(isItemCompleted: false)
    }
    .padding()
}

#Preview("Completed Item in Active List") {
    HStack {
        ItemStatusBadge(isItemCompleted: true)
    }
    .padding()
}
