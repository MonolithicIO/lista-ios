//
//  HomeContentView.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI

struct HomeScreen: View {
    @Environment(NavigationCoordinator.self) private var coordinator:
        NavigationCoordinator

    @StateObject private var viewModel: HomeScreen.ViewModel
    @State private var isPresentingNewList: Bool = false

    init(
        viewModel: HomeScreen.ViewModel = InstanceKeeper.shared
            .provideHomeViewModel()
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        HomeScreenView(
            items: viewModel.items,
            searchText: .constant(""),
            selectedFilter: .constant(.active),
            onAction: { action in
                switch action {
                case .onAddTap:
                    isPresentingNewList = true
                case .onItemTap(let item):
                    coordinator.push(
                        .details(listaId: item.id, listaTitle: item.title)
                    )
                case .onSettingsTap:
                    coordinator.push(.settings)
                }
            }
        ).task {
            await viewModel.onAppear()
        }
        .sheet(isPresented: $isPresentingNewList) {
            NavigationStack {
                AddListView { title in
                    viewModel.addList(title: title)
                    isPresentingNewList = true
                }
            }
        }
    }
}

extension HomeScreenView {
    enum Actions {
        case onSettingsTap
        case onAddTap
        case onItemTap(ListaUiModel)
    }
}

private struct HomeScreenView: View {
    let items: [ListaUiModel]
    @Binding var searchText: String
    @Binding var selectedFilter: HomeScreen.Filter
    let onAction: (Actions) -> Void

    var body: some View {
        Group {
            if items.isEmpty {
                EmptyStateView(
                    title: "No lists created",
                    description:
                        "Tap the plus button to create your first list.",
                    iconName: "list.bullet"
                )
            } else {
                List(items) { item in
                    Button {
                        onAction(.onItemTap(item))
                    } label: {
                        Text(item.title)
                            .font(.body)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Lists")
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search lists"
        )
        .toolbar {
            // Settings
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    onAction(.onSettingsTap)
                }) {
                    Image(systemName: "gearshape")
                }
            }

            // Add
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    onAction(.onAddTap)
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New lsit")
            }

            // Filtro
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(HomeScreen.Filter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeScreenView(
            items: [
                ListaUiModel(id: "123", title: "Presentes de natal"),
                ListaUiModel(id: "321", title: "Presentes de natal"),
            ],
            searchText: .constant(""),
            selectedFilter: .constant(.active),
            onAction: { _ in }
        )
    }
}
