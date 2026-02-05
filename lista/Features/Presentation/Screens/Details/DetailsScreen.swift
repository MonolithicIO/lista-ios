//
//  DetailsContentView.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI

struct DetailsScreen: View {
    let listaId: String
    let listaTitle: String

    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationCoordinator.self) private var coordinator:
        NavigationCoordinator

    @StateObject var viewModel: DetailsViewModel

    init(
        viewModel: DetailsViewModel = InstanceKeeper.shared
            .provideDetailsViewModel(),
        listaId: String,
        listaTitle: String
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.listaId = listaId
        self.listaTitle = listaTitle
    }

    var body: some View {
        DetailsScreenView(
            listaId: listaId,
            title: listaTitle,
            isArchived: viewModel.isArchived,
            isCompleted: viewModel.isCompleted,
            updatedAt: viewModel.updatedAt,
            items: viewModel.items,
            onAction: { action in
                switch action {
                case .onAddItem:
                    coordinator.push(
                        .insertItem(listId: self.listaId, itemId: nil)
                    )
                case .onToggleItemState(let changedItem):
                    viewModel.onToogleItemState(item: changedItem)
                case .onDelete:
                    viewModel.onDeleteList()
                case .onArchive:
                    viewModel.setArchiveState(state: true)
                case .onUndoArchive:
                    viewModel.setArchiveState(state: false)
                case .onComplete:
                    viewModel.setCompletedState(state: true)
                case .onUndoComplete:
                    viewModel.setCompletedState(state: false)
                case .onUpdateItem(let item):
                    coordinator.push(
                        .insertItem(listId: self.listaId, itemId: item.id)
                    )
                case .onDeleteItem(let item):
                    viewModel.onDeleteItem(itemId: item.id)
                }
            }
        )
        .task {
            viewModel.onAppear(listaId: listaId)
        }
        .onChange(of: self.viewModel.events) { _, newValue in
            if let event = newValue {
                self.handleEvent(event: event)
            }
        }
    }

    private func handleEvent(event: DetailsViewModel.Events) {
        switch event {

        case .deleteSuccess:
            dismiss()
        }
    }
}

private struct DetailsScreenView: View {
    let listaId: String
    let title: String
    let isArchived: Bool
    let isCompleted: Bool
    let updatedAt: Date?
    let items: [ListaItemUiModel]
    let onAction: (DetailsScreenView.Actions) -> Void

    @State private var presentation: DetailsScreenPresentation? = nil
    @State private var detailsToPresent: ListaItemUiModel? = nil

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
                    description: String(localized: "empty.no_items.description"),
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
                List {
                    ForEach(items) { item in
                        var actionOpacity: Double {
                            if listEditEnabled {
                                return 1.0
                            } else {
                                return 0.3
                            }
                        }

                        ListaItemRowView(
                            item: item,
                            onToggle: { item in
                                onAction(.onToggleItemState(item))
                            },
                            onTap: { item in
                                detailsToPresent = item
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
                                    item.isCompleted ? String(localized: "swipe_action.undo") : String(localized: "swipe_action.complete"),
                                    systemImage: item.isCompleted
                                        ? "arrow.uturn.backward" : "checkmark"
                                )
                            }
                            .tint(
                                item.isCompleted
                                    ? AppColors.orange.opacity(
                                        actionOpacity
                                    )
                                    : AppColors.green.opacity(
                                        actionOpacity
                                    )
                            )
                            .disabled(!listEditEnabled)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                onAction(.onDeleteItem(item))
                            } label: {
                                Label(String(localized: "swipe_action.delete"), systemImage: "trash")
                            }
                            .tint(AppColors.destructive.opacity(actionOpacity))
                            .disabled(!listEditEnabled)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(AppColors.background)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(title)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                DetailsContextMenuView(
                    isCompleted: isCompleted,
                    isArquived: isArchived,
                    onAction: { action in
                        switch action {
                        case .archive:
                            presentation = .confirmArchive
                        case .undoArchive:
                            onAction(.onUndoArchive)
                        case .delete:
                            presentation = .confirmDelete
                        case .complete:
                            presentation = .confirmComplete
                        case .undoComplete:
                            onAction(.onUndoComplete)
                        }
                    }
                )

                Button(action: {
                    onAction(.onAddItem)
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(String(localized: "accessibility.add_item"))
                .disabled(isArchived || isCompleted)
            }
        }
        .alert(
            String(localized: "alert.delete_list.title"),
            isPresented: .constant(isConfirmDeletePresented),
        ) {
            Button(String(localized: "alert.button.delete"), role: .destructive) {
                onAction(.onDelete)
                presentation = nil
            }
            Button(String(localized: "alert.button.cancel"), role: .cancel) {
                presentation = nil
            }
        } message: {
            Text(String(localized: "alert.delete_list.message"))
        }
        .alert(
            String(localized: "alert.archive_list.title"),
            isPresented: .constant(isConfirmArchivePresented),
            actions: {
                Button(String(localized: "alert.button.archive"), role: .destructive) {
                    onAction(.onArchive)
                    presentation = nil
                }
                Button(String(localized: "alert.button.cancel"), role: .cancel) {
                    presentation = nil
                }
            },
            message: {
                Text(String(localized: "alert.archive_list.message"))
            }
        )
        .alert(
            String(localized: "alert.complete_list.title"),
            isPresented: .constant(isConfirmCompletePresented),
            actions: {
                Button(String(localized: "alert.button.complete"), role: .destructive) {
                    onAction(.onComplete)
                    presentation = nil
                }
                Button(String(localized: "alert.button.cancel"), role: .cancel) {
                    presentation = nil
                }
            },
            message: {
                Text(String(localized: "alert.complete_list.message"))
            }
        )
        .sheet(
            isPresented: Binding(
                get: {
                    detailsToPresent != nil
                },
                set: { isPresented in
                    if !isPresented {
                        detailsToPresent = nil
                    }
                }
            )
        ) {
            if let itemDetails = detailsToPresent {
                ItemDetailsView(
                    item: itemDetails,
                    onUpdate: {
                        detailsToPresent = nil
                        onAction(.onUpdateItem(itemDetails))
                    },
                    onToggle: {
                        onAction(.onToggleItemState(itemDetails))
                        detailsToPresent = nil
                    },
                    enableEdit: listEditEnabled
                )
            }
        }
    }
}

// MARK: - Derived States
extension DetailsScreenView {
    private var isConfirmDeletePresented: Bool {
        if case .confirmDelete = presentation {
            return true
        }
        return false
    }

    private var isConfirmArchivePresented: Bool {
        if case .confirmArchive = presentation {
            return true
        }
        return false
    }

    private var isConfirmCompletePresented: Bool {
        if case .confirmComplete = presentation {
            return true
        }
        return false
    }

    private var listEditEnabled: Bool {
        return !isArchived && !isCompleted
    }
}

extension DetailsScreenView {
    enum DetailsScreenPresentation {
        case confirmDelete
        case confirmArchive
        case confirmComplete
    }

    enum Actions {
        case onAddItem
        case onToggleItemState(ListaItemUiModel)
        case onDelete
        case onArchive
        case onUndoArchive
        case onComplete
        case onUndoComplete
        case onUpdateItem(ListaItemUiModel)
        case onDeleteItem(ListaItemUiModel)
    }
}

#Preview {
    NavigationStack {
        DetailsScreenView(
            listaId: "123",
            title: "Lista Sample",
            isArchived: false,
            isCompleted: true,
            updatedAt: Date(),
            items: [
                ListaItemUiModel(
                    listId: "123",
                    id: UUID().uuidString,
                    title: "Buy groceries",
                    description: "Milk, eggs, bread",
                    url: nil,
                    isCompleted: false,
                    image: nil,
                    updatedAt: nil
                )
            ],
            onAction: { _ in }
        )
    }
}
