//
//  ListaItemRowView.swift
//  lista
//
//  Created by Lucca Beurmann on 23/01/26.
//

import SwiftUI

struct ListaItemRowView: View {
    let item: ListaItemUiModel
    let enableToggle: Bool
    let onToggle: (ListaItemUiModel) -> Void
    let onTap: (ListaItemUiModel) -> Void
    var onDelete: ((ListaItemUiModel) -> Void)? = nil
    var onEdit: ((ListaItemUiModel) -> Void)? = nil

    var body: some View {
        Button {
            onTap(item)
        } label: {
            HStack(spacing: 12) {
                RadioButton(
                    isChecked: item.isCompleted,
                    onToggle: { onToggle(item) },
                    isEnabled: enableToggle
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(AppColors.cardForeground)
                        .lineLimit(1)
                        .strikethrough(
                            item.isCompleted,
                            pattern: .solid,
                            color: AppColors.cardForeground
                        )
                    ItemMetadataView(metadata: item.getMetadata())

                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColors.mutedForeground)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

extension ListaItemUiModel {
    fileprivate func getMetadata() -> [ItemMetadata] {
        var response: [ItemMetadata] = []
        
        if let description {
            if !description.isEmpty {
                response.append(.description)
            }
        }

        if self.url != nil {
            response.append(.link)
        }

        if self.image != nil {
            response.append(.image)
        }

        return response
    }
}

#Preview {
    ListaItemRowView(
        item: ListaItemUiModel(
            listId: "123",
            id: UUID().uuidString,
            title: "Buy groceries",
            description: "Milk, eggs, bread",
            url: nil,
            isCompleted: false,
            image: nil,
            updatedAt: nil
        ),
        enableToggle: false
    ) { item in

    } onTap: { item in

    } onDelete: { item in

    } onEdit: { item in

    }

    ListaItemRowView(
        item: ListaItemUiModel(
            listId: "123",
            id: UUID().uuidString,
            title: "Buy groceries",
            description: "Milk, eggs, bread",
            url: nil,
            isCompleted: true,
            image: nil,
            updatedAt: nil
        ),
        enableToggle: false
    ) { item in

    } onTap: { item in

    } onDelete: { item in

    } onEdit: { item in

    }
}
