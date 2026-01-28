//
//  StatusBadge.swift
//  lista
//
//  Created by Lucca Beurmann on 28/01/26.
//

import Foundation
import SwiftUI

struct ListStatusBadge: View {
    enum Status {
        case active
        case completed
        case archived
    }

    let status: Status

    var body: some View {
        Label {
            Text(title)
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
        switch status {
        case .active:
            return "Active"
        case .completed:
            return "Completed"
        case .archived:
            return "Archived"
        }
    }

    private var systemImage: String {
        switch status {
        case .active:
            return "circle"
        case .completed:
            return "checkmark.circle.fill"
        case .archived:
            return "archivebox.fill"
        }
    }

    private var foregroundStyle: Color {
        switch status {
        case .active:
            return .secondary
        case .completed:
            return .green
        case .archived:
            return .orange
        }
    }

    private var backgroundStyle: Color {
        switch status {
        case .active:
            return AppColors.blue.opacity(0.15)
        case .completed:
            return AppColors.green.opacity(0.15)
        case .archived:
            return AppColors.orange.opacity(0.15)
        }
    }

    private var accessibilityLabel: String {
        "List status: \(title)"
    }
}
