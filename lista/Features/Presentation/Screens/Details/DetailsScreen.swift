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
                }
            },
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
    let title: String
    let isArchived: Bool
    let isCompleted: Bool
    let updatedAt: Date?
    let items: [ListaItemUiModel]
    let onAction: (DetailsScreenView.Actions) -> Void

    @State private var presentation: DetailsScreenPresentation? = nil

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
                        presentation = .addItem
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
                            onTap: { _ in
                            },
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
                    presentation = .addItem
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Item")
                .disabled(isArchived || isCompleted)
            }
        }
        .alert(
            "Are you sure you want to delete this list?",
            isPresented: .constant(presentation == .confirmDelete),
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
            isPresented: .constant(presentation == .confirmArchive),
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
            isPresented: .constant(presentation == .confirmComplete),
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
        .sheet(isPresented: .constant(presentation == .addItem)) {
            InsertItemView(
                onSubmit: { newItem in
                    onAction(.onAddItem(newItem))
                },
                onDismiss: {
                    presentation = nil
                },
            )
        }
    }
}

extension DetailsScreenView {
    enum DetailsScreenPresentation {
        case addItem
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
    }
}

#Preview {
    NavigationStack {
        DetailsScreenView(
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
