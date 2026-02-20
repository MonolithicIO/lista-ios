//
//  ListCard.swift
//  lista
//
//  Redesigned with modern card-based layout
//

import Foundation
import SwiftUI

struct ListaCardView: View {
    let item: ListaUiModel

    var body: some View {
        // Pre-computed values to avoid redundant calculations
        let isCompleted =
            item.completedCount == item.itemCount && item.itemCount > 0
        let completionColor: Color =
            isCompleted ? AppColors.green : AppColors.mutedForeground
        let iconColor: Color = {
            switch item.status {
            case .active: return AppColors.blue
            case .completed: return AppColors.green
            case .archived: return AppColors.orange
            }
        }()

        HStack(spacing: 12) {
            Image(systemName: "list.bullet")
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppColors.cardForeground)
                    .lineLimit(1)

                // Stats row
                HStack(spacing: 4) {
                    Text(.detailsItemCount(itemCounte: item.itemCount))
                        .font(.caption)
                        .foregroundStyle(AppColors.mutedForeground)

                    Text("•")
                        .font(.caption)
                        .foregroundStyle(AppColors.mutedForeground)

                    Text(
                        .detailsCompletedCount(
                            completedCount: item.completedCount
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(completionColor)

                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(AppColors.green)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppColors.mutedForeground)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.card)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }
}

#Preview("Active List") {
    ListaCardView(
        item: ListaUiModel(
            id: "123",
            title: "Groceries",
            itemCount: 12,
            completedCount: 5,
            status: .active
        )
    )
    .padding()
}

#Preview("Completed List") {
    ListaCardView(
        item: ListaUiModel(
            id: "123",
            title: "Weekend Tasks",
            itemCount: 8,
            completedCount: 8,
            status: .active
        )
    )
    .padding()
}

#Preview("Empty List") {
    ListaCardView(
        item: ListaUiModel(
            id: "123",
            title: "New List",
            itemCount: 0,
            completedCount: 0,
            status: .active
        )
    )
    .padding()
}
