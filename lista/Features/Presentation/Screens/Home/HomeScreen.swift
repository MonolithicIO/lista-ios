//
//  HomeContentView.swift
//  lista
//
//  Redesigned with modern card-based layout
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @StateObject private var viewModel: HomeViewModel
    @State private var showAddListModal: Bool = false

    init(
        viewModel: HomeViewModel = InstanceKeeper.shared
            .provideHomeViewModel()
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        HomeScreenView(
            items: viewModel.items,
            selectedFilter: $viewModel.filter,
            onAction: { action in
                switch action {
                case .onItemTap(let item):
                    coordinator.push(
                        .details(listaId: item.id, listaTitle: item.title)
                    )

                case .onRemoveItem(let item):
                    viewModel.removeList(list: item)

                case .onAddTap:
                    showAddListModal = true
                }
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("navigation.lists")
        .searchable(
            text: $viewModel.searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "placeholder.search_lists"
        )
        .toolbar {

            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    coordinator.push(.settings)
                }) {
                    Image(systemName: "gearshape")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showAddListModal = true
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(
                    "accessibility.new_list"
                )
            }
        }
        .task {
            viewModel.loadLists()
        }
        .onChange(of: viewModel.filter) { _, _ in
            viewModel.loadLists()
        }
        .sheet(
            isPresented: $showAddListModal
        ) {
            NavigationStack {
                AddListView(
                    onSubmit: { title in
                        viewModel.addList(title: title)
                        showAddListModal = false
                    }
                )
            }
        }
    }
}

extension HomeScreenView {
    enum Actions {
        case onItemTap(ListaUiModel)
        case onRemoveItem(ListaUiModel)
        case onAddTap
    }
}

private struct HomeScreenView: View {
    let items: [ListaUiModel]
    @Binding var selectedFilter: HomeFilter
    let onAction: (Actions) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Segmented Filter Control - Always visible
            Picker(
                "accessibility.filter",
                selection: $selectedFilter
            ) {
                ForEach(HomeFilter.allCases) { filter in
                    Text(LocalizedStringKey(filter.displayName)).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 4)
            .padding(.top, 8)
            .padding(.bottom, 12)

            // Content area - fills remaining space
            if items.isEmpty {
                EmptyStateView(
                    title: String(localized: "empty.no_results.title"),
                    description: String(
                        localized: "empty.no_results.description"
                    ),
                    iconName: "list.bullet",
                    actionTitle: String(localized: "empty.no_results.button"),
                    onAction: {
                        onAction(.onAddTap)
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(items) { item in
                    Button {
                        onAction(.onItemTap(item))
                    } label: {
                        ListaCardView(item: item)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(
                        .init(top: 8, leading: 0, bottom: 8, trailing: 0)
                    )
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            onAction(.onRemoveItem(item))
                        } label: {
                            Label(
                                "swipe_action.delete",
                                systemImage: "trash"
                            )
                            .tint(AppColors.destructive)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeScreenView(
            items: [
                ListaUiModel(
                    id: "123",
                    title: "Groceries",
                    itemCount: 12,
                    completedCount: 5,
                    status: .active
                ),
                ListaUiModel(
                    id: "321",
                    title: "Weekend Tasks",
                    itemCount: 8,
                    completedCount: 8,
                    status: .active
                ),
                ListaUiModel(
                    id: "456",
                    title: "Work Projects",
                    itemCount: 15,
                    completedCount: 3,
                    status: .active
                ),
            ],
            selectedFilter: .constant(.active),
            onAction: { _ in }
        )
    }
}
