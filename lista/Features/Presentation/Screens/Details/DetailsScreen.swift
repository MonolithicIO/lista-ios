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
    @State private var showingNewItemSheet: Bool = false

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
            items: viewModel.items,
            onAddItem: {
                showingNewItemSheet = true
            },
            onToggleItemState: { item in
                Task {
                    await viewModel.onToogleItemState(item: item)
                }
            },
            onDelete: {
                Task {
                    await viewModel.onDeleteList(listaId: listaId)
                    dismiss()
                }
            }
        )
        .task {
            await viewModel.onAppear(listaId: listaId)
        }
        .sheet(isPresented: $showingNewItemSheet) {
            InsertItemView(
                onSubmit: { newItem in
                    Task {
                        await viewModel.onAddNewItem(
                            item: newItem,
                            listaId: self.listaId
                        )
                    }
                },
                onDismiss: {
                    showingNewItemSheet = false
                },
            )
        }
    }
}

private struct DetailsScreenView: View {
    let title: String
    let items: [ListaItemUiModel]
    let onAddItem: () -> Void
    let onToggleItemState: (ListaItemUiModel) -> Void
    let onDelete: () -> Void
    
    @State private var isDeleteDialogVisible: Bool = false

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
                    onArchive: {},
                    onDelete: {
                        isDeleteDialogVisible = true
                    },
                    onComplete: {},
                    onRestore: {},
                    isCompleted: false
                )

                Button(action: onAddItem) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Item")
            }
        }
        .alert(
            "Are you sure you want to delete this list?",
            isPresented: $isDeleteDialogVisible,
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {
                isDeleteDialogVisible = false
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

#Preview {
    NavigationStack {
        DetailsScreenView(
            title: "Lista Sample",
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
            onAddItem: {},
            onToggleItemState: { _ in },
            onDelete: {}
        )
    }
}
