//
//  DetailsContentView.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI

struct DetailsScreen: View {
    @Environment(NavigationCoordinator.self) private var coordinator: NavigationCoordinator

    let listaId: String
    let listaTitle: String
    @StateObject var viewModel: DetailsScreen.ViewModel

    @State private var showingNewItemSheet: Bool = false
    @State private var newItemTitle: String = ""

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
                title: $newItemTitle,
                onCancel: {
                    newItemTitle = ""
                    showingNewItemSheet = false
                },
                onSubmit: {
                    Task {
                        newItemTitle = ""
                        showingNewItemSheet = false
                        
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
    @Binding var title: String
    let onCancel: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("New Item")) {
                    TextField("Title", text: $title)
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSubmit()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
