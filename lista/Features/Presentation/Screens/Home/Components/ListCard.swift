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
        HStack(spacing: 12) {
            // List icon
            Image(systemName: "list.bullet")
                .font(.title3)
                .foregroundStyle(AppColors.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppColors.cardForeground)
                    .lineLimit(1)

                // Stats row
                HStack(spacing: 4) {
                    Text("\(item.itemCount) items")
                        .font(.caption)
                        .foregroundStyle(AppColors.mutedForeground)

                    Text("•")
                        .font(.caption)
                        .foregroundStyle(AppColors.mutedForeground)

                    Text("\(item.completedCount) completed")
                        .font(.caption)
                        .foregroundStyle(completionColor)

                    if item.completedCount == item.itemCount && item.itemCount > 0 {
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

    private var completionColor: Color {
        if item.completedCount == item.itemCount && item.itemCount > 0 {
            return AppColors.green
        }
        return AppColors.mutedForeground
    }
}

#Preview("Active List") {
    ListaCardView(
        item: ListaUiModel(
            id: "123",
            title: "Groceries",
            itemCount: 12,
            completedCount: 5
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
            completedCount: 8
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
            completedCount: 0
        )
    )
    .padding()
}
