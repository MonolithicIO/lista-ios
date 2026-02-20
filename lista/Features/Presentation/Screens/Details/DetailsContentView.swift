//
//  DetailsContent.swift
//  lista
//
//  Created by Lucca Beurmann on 12/02/26.
//

import Foundation
import SwiftUI

struct DetailsContentView: View {
    let updatedAt: Date?
    let isArchived: Bool
    let isCompleted: Bool
    let isEditEnabled: Bool
    let items: [ListaItemUiModel]
    let onAction: (Actions) -> Void

    var body: some View {
        VStack(spacing: 0) {

            if let updatedAt {
                LastUpdatedView(date: updatedAt)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            }

            ListStatusBadge(
                status: isArchived
                    ? .archived : isCompleted ? .completed : .active
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)

            if items.isEmpty {
                EmptyStateView(
                    title: String(localized: "empty.no_items.title"),
                    description: String(
                        localized: "empty.no_items.description"
                    ),
                    iconName: "list.bullet",
                    actionTitle: String(localized: "empty.no_items.button"),
                    onAction: {
                        onAction(.onAddItem)
                    }
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
                .padding()
            } else {
                let actionOpacity = isEditEnabled ? 1.0 : 0.3

                List {
                    ForEach(items) { item in
                        ListaItemRowView(
                            item: item,
                            onToggle: { item in
                                onAction(.onToggleItemState(item))
                            },
                            onTap: { item in
                                onAction(.onTapItem(item))
                            }
                        )
                        .listRowBackground(AppColors.background)
                        .listRowSeparator(.hidden)
                        .listRowInsets(
                            .init(top: 8, leading: 0, bottom: 8, trailing: 0)
                        )
                        .swipeActions(edge: .leading) {
                            Button {
                                onAction(.onToggleItemState(item))
                            } label: {
                                Label(
                                    item.isCompleted
                                        ? "swipe_action.undo"
                                        : "swipe_action.complete",
                                    systemImage: item.isCompleted
                                        ? "arrow.uturn.backward" : "checkmark"
                                )
                            }
                            .tint(
                                item.isCompleted
                                    ? AppColors.orange.opacity(actionOpacity)
                                    : AppColors.green.opacity(actionOpacity)
                            )
                            .disabled(!isEditEnabled)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                onAction(.onDeleteItem(item))
                            } label: {
                                Label(
                                    "swipe_action.delete",
                                    systemImage: "trash"
                                )
                            }
                            .tint(AppColors.destructive.opacity(actionOpacity))
                            .disabled(!isEditEnabled)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(AppColors.background)
            }
        }
    }
}

extension DetailsContentView {
    enum Actions {
        case onAddItem
        case onToggleItemState(ListaItemUiModel)
        case onUpdateItem(ListaItemUiModel)
        case onDeleteItem(ListaItemUiModel)
        case onTapItem(ListaItemUiModel)
    }
}
