//
//  ListaItemRowView.swift
//  lista
//
//  Created by Lucca Beurmann on 23/01/26.
//

import SwiftUI

struct ListaItemRowView: View {
    let item: ListaItemUiModel
    let onTap: (ListaItemUiModel) -> Void
    var onDelete: ((ListaItemUiModel) -> Void)? = nil
    var onEdit: ((ListaItemUiModel) -> Void)? = nil

    var body: some View {
        Button {
            onTap(item)
        } label: {
            HStack(spacing: 12) {
                // Ícone à esquerda
                ZStack {
                    Circle()
                        .fill(AppColors.card)
                        .frame(width: 36, height: 36)

                    Image(systemName: "checklist")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.accent)
                }

                // Conteúdo centralizado verticalmente
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(AppColors.foreground)
                        .lineLimit(1)

                    if let description = item.description, !description.isEmpty
                    {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.mutedForeground)
                            .lineLimit(2)
                    }

                    if let link = item.url, !link.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.caption)
                                .foregroundStyle(AppColors.mutedForeground)
                            Text(link)
                                .font(.caption)
                                .foregroundStyle(AppColors.mutedForeground)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Disclosure
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColors.mutedForeground)
            }
            .frame(maxWidth: .infinity, alignment: .center)  // centraliza o conteúdo do HStack no card
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColors.card)  // cor uniforme do card
            )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

#Preview("Centered") {
    VStack(spacing: 12) {
        ListaItemRowView(
            item: .init(
                listId: "123",
                id: "1234",
                title: "Buy groceries for the week",
                description: "Milk, eggs, bread, fruits, and veggies.",
                url: "https://example.com"
            ),
            onTap: { _ in }
        )

        ListaItemRowView(
            item: .init(
                listId: "12345",
                id: "123444",
                title: "Read a book",
                description: nil,
                url: nil
            ),
            onTap: { _ in }
        )
    }
    .padding()
    .background(AppColors.background)
}
