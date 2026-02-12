//
//  ListaItemRowView.swift
//  lista
//
//  Created by Lucca Beurmann on 23/01/26.
//

import SwiftUI

struct ListaItemRowView: View {
    let item: ListaItemUiModel
    let onToggle: (ListaItemUiModel) -> Void
    let onTap: (ListaItemUiModel) -> Void
    var onDelete: ((ListaItemUiModel) -> Void)? = nil
    var onEdit: ((ListaItemUiModel) -> Void)? = nil

    var body: some View {
        Button {
            onTap(item)
        } label: {
            HStack(spacing: 12) {
                // Status indicator strip
                statusIndicator
                    .frame(width: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(AppColors.cardForeground)
                        .lineLimit(1)
                        .opacity(item.isCompleted ? 0.6 : 1.0)
                    ItemMetadataView(metadata: item.getMetadata())

                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColors.mutedForeground)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
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
        .contentShape(Rectangle())
    }

    private var statusIndicator: some View {
        Rectangle()
            .fill(item.isCompleted ? AppColors.green : AppColors.orange)
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
    ) { item in

    } onTap: { item in

    } onDelete: { item in

    } onEdit: { item in

    }
}
