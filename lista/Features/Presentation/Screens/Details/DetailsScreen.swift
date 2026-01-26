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
                    await viewModel.onToggleState(item: item)
                }
            }
        )
        .task {
            await viewModel.onAppear(listaId: listaId)
        }
        .fullScreenCover(isPresented: $showingNewItemSheet) {
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
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onAddItem) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Item")
            }
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
            onToggleItemState: {_ in}
        )
    }
}
