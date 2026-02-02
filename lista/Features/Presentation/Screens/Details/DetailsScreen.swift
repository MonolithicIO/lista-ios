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
                case .onAddItem(let newItem):
                    viewModel.onAddNewItem(item: newItem)
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
                case .onUpdateItem(let dto):
                    viewModel.onUpdateItem(dto: dto)
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

    // Helper computed properties for presentation state checks
    private var isItemFormPresented: Bool {
        if case .itemForm = presentation {
            return true
        }
        return false
    }

    private var itemFormMode: ItemFormMode? {
        if case .itemForm(let mode) = presentation {
            return mode
        }
        return nil
    }

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
                    title: "No items yet",
                    description: "Tap the + button to add your first item.",
                    iconName: "list.bullet",
                    actionTitle: "Create item",
                    onAction: {
                        presentation = .itemForm(.write(.create(listId: listaId)))
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
                        ListaItemRowView(
                            item: item,
                            enableToggle: !isArchived && !isCompleted,
                            onToggle: { item in
                                onAction(.onToggleItemState(item))
                            },
                            onTap: { item in
                                presentation = .itemForm(.read(item))
                            }
                        )
                        .listRowBackground(AppColors.background)
                        .listRowSeparator(.hidden)
                        .listRowInsets(
                            .init(top: 8, leading: 0, bottom: 8, trailing: 0)
                        )
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
                    presentation = .itemForm(.write(.create(listId: listaId)))
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Item")
                .disabled(isArchived || isCompleted)
            }
        }
        .alert(
            "Are you sure you want to delete this list?",
            isPresented: .constant(isConfirmDeletePresented),
        ) {
            Button("Delete", role: .destructive) {
                onAction(.onDelete)
                presentation = nil
            }
            Button("Cancel", role: .cancel) {
                presentation = nil
            }
        } message: {
            Text(
                "This action cannot be undone."
            )
        }
        .alert(
            "Archive this list?",
            isPresented: .constant(isConfirmArchivePresented),
            actions: {
                Button("Archive", role: .destructive) {
                    onAction(.onArchive)
                    presentation = nil
                }
                Button("Cancel", role: .cancel) {
                    presentation = nil
                }
            },
            message: {
                Text(
                    "Archived lists cannot be edited. Restore this list before making changes"
                )
            }
        )
        .alert(
            "Complete this list?",
            isPresented: .constant(isConfirmCompletePresented),
            actions: {
                Button("Complete", role: .destructive) {
                    onAction(.onComplete)
                    presentation = nil
                }
                Button("Cancel", role: .cancel) {
                    presentation = nil
                }
            },
            message: {
                Text(
                    "Completing a list will mark all items as done. Once completed a list cannot be edited, undo this action before making changes "
                )
            }
        )
        .fullScreenCover(isPresented: .constant(isItemFormPresented)) {
            if let mode = itemFormMode {
                ItemFormView(
                    mode: mode,
                    isParentListCompleted: isCompleted,
                    onCreate: { newItem in
                        onAction(.onAddItem(newItem))
                    },
                    onUpdate: { dto in
                        onAction(.onUpdateItem(dto))
                    },
                    onDismiss: {
                        presentation = nil
                    }
                )
            }
        }
    }
}

extension DetailsScreenView {
    enum DetailsScreenPresentation {
        case itemForm(ItemFormMode)
        case confirmDelete
        case confirmArchive
        case confirmComplete
    }

    enum Actions {
        case onAddItem(AddListaItemUiModel)
        case onToggleItemState(ListaItemUiModel)
        case onDelete
        case onArchive
        case onUndoArchive
        case onComplete
        case onUndoComplete
        case onUpdateItem(UpdateListItemDTO)
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
                    image: nil
                )
            ],
            onAction: { _ in }
        )
    }
}
