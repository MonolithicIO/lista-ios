//
//  DetailsContentView.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI

struct DetailsScreen: View {
    @StateObject var viewModel: DetailsScreen.ViewModel
    @State private var showingNewItemSheet: Bool = false

    let listaId: String
    let listaTitle: String

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
            }
        )
        .task {
            await viewModel.onAppear(listaId: listaId)
        }
        .sheet(isPresented: $showingNewItemSheet) {
            NewItemFormView(
                onCancel: {
                    showingNewItemSheet = false
                },
                onSubmit: { newTitle in
                    showingNewItemSheet = false
                    Task {
                        await viewModel.onAddNewItem(
                            title: newTitle,
                            listaId: self.listaId
                        )
                    }
                }
            )
        }
    }
}

private struct DetailsScreenView: View {
    let title: String
    let items: [ListaItemUiModel]
    let onAddItem: () -> Void
    @State private var newItemTitle: String = ""

    var body: some View {
        VStack {
            ListaItemsView(
                items: items,
                onItemTap: { _ in
                    // Handle item tap if needed
                }
            )
            .padding(.horizontal)
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

private struct NewItemFormView: View {
    let onCancel: () -> Void
    let onSubmit: (String) -> Void
    @State private var newItemTitle: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("New Item")) {
                    TextField("Title", text: $newItemTitle)
                }
            }.padding(.vertical, 16)
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSubmit(self.newItemTitle)
                        newItemTitle = ""
                    }
                    .disabled(
                        newItemTitle.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        .isEmpty
                    )
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailsScreenView(
            title: "Lista Sample",
            items: [],
            onAddItem: {}
        )
    }
}
