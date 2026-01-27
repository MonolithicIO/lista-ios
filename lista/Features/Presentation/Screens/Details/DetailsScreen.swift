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
    @StateObject var viewModel: DetailsScreen.ViewModel

    init(
        viewModel: DetailsScreen.ViewModel = InstanceKeeper.shared
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
            items: viewModel.items,
            onAddItem: viewModel.onAddNewItem,
            onToggleItemState: viewModel.onToogleItemState,
            onDelete: {
                viewModel.onDeleteList()
                dismiss()
            },
            onArchive: {
                viewModel.setArchiveState(state: true)
            },
            onUndoArchive: {
                viewModel.setArchiveState(state: false)
            }
        )
        .task {
            viewModel.onAppear(listaId: listaId)
        }
    }
}

private enum DetailsScreenPresentation {
    case addItem
    case confirmDelete
    case confirmArchive
}

private struct DetailsScreenView: View {
    let title: String
    let isArchived: Bool
    let items: [ListaItemUiModel]
    let onAddItem: (AddListaItemUiModel) -> Void
    let onToggleItemState: (ListaItemUiModel) -> Void
    let onDelete: () -> Void
    let onArchive: () -> Void
    let onUndoArchive: () -> Void

    @State private var presentation: DetailsScreenPresentation? = nil

    var body: some View {
        VStack(spacing: 0) {
            if items.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 44))
                        .foregroundStyle(AppColors.mutedForeground)
                    Text("No items yet")
                        .font(.headline)
                        .foregroundStyle(AppColors.foreground)
                    Text("Tap the + button to add your first item.")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.mutedForeground)
                }
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
                            onToggle: { item in
                                onToggleItemState(item)
                            },
                            onTap: { _ in
                            }
                        )
                        .listRowBackground(AppColors.background)
                        .listRowSeparator(.hidden)
                        .listRowInsets(
                            .init(top: 8, leading: 16, bottom: 8, trailing: 16)
                        )
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(AppColors.background)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(title)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                DetailsContextMenuView(
                    isCompleted: false,
                    isArquived: isArchived,
                    onAction: { action in
                        switch action {
                        case .archive:
                            presentation = .confirmArchive
                        case .undoArchive:
                            onUndoArchive()
                        case .delete:
                            presentation = .confirmDelete
                        case .complete:
                            return
                        case .undoComplete:
                            return
                        }
                    }
                )

                Button(action: {
                    presentation = .addItem
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Item")
                .disabled(isArchived)
            }
        }
        .alert(
            "Are you sure you want to delete this list?",
            isPresented: .constant(presentation == .confirmDelete),
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
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
                    onArchive()
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
        .sheet(isPresented: .constant(presentation == .addItem)) {
            InsertItemView(
                onSubmit: { newItem in
                    onAddItem(newItem)
                },
                onDismiss: {
                    presentation = nil
                },
            )
        }
    }
}

#Preview {
    NavigationStack {
        DetailsScreenView(
            title: "Lista Sample",
            isArchived: false,
            items: [
                ListaItemUiModel(
                    listId: "123",
                    id: UUID().uuidString,
                    title: "Buy groceries",
                    description: "Milk, eggs, bread",
                    url: nil,
                    isCompleted: false
                )
            ],
            onAddItem: { _ in },
            onToggleItemState: { _ in },
            onDelete: {},
            onArchive: {

            },
            onUndoArchive: {

            }
        )
    }
}
