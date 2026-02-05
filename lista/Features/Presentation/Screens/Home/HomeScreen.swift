//
//  HomeContentView.swift
//  lista
//
//  Redesigned with modern card-based layout
//

import SwiftUI

struct HomeScreen: View {
    @Environment(NavigationCoordinator.self) private var coordinator:
        NavigationCoordinator

    @StateObject private var viewModel: HomeViewModel
    @State private var presentation: HomeScreenView.Presentation? = nil

    init(
        viewModel: HomeViewModel = InstanceKeeper.shared
            .provideHomeViewModel()
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        HomeScreenView(
            items: viewModel.items,
            searchText: $viewModel.searchQuery,
            selectedFilter: $viewModel.filter,
            presentation: $presentation,
            onAction: { action in
                switch action {
                case .onAddTap:
                    presentation = .addList
                case .onItemTap(let item):
                    coordinator.push(
                        .details(listaId: item.id, listaTitle: item.title)
                    )
                case .onSettingsTap:
                    coordinator.push(.settings)
                case .onAddItem(let title):
                    viewModel.addList(title: title)
                    presentation = nil
                case .onRemoveItem(let item):
                    viewModel.removeList(list: item)
                }
            }
        ).task {
            viewModel.onAppear()
        }
        .onChange(of: viewModel.filter) { _, _ in
            viewModel.onAppear()
        }
        .onChange(of: viewModel.searchQuery) { _, _ in
            viewModel.onChangeSearchQuery()
        }
    }
}

extension HomeScreenView {
    enum Actions {
        case onSettingsTap
        case onAddTap
        case onAddItem(String)
        case onItemTap(ListaUiModel)
        case onRemoveItem(ListaUiModel)
    }

    enum Presentation {
        case addList
    }
}

private struct HomeScreenView: View {
    let items: [ListaUiModel]
    @Binding var searchText: String
    @Binding var selectedFilter: HomeFilter
    @Binding var presentation: Presentation?
    let onAction: (Actions) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Segmented Filter Control - Always visible
            Picker(String(localized: "accessibility.filter"), selection: $selectedFilter) {
                ForEach(HomeFilter.allCases) { filter in
                    Text(filter.displayName).tag(filter)
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
                    description: String(localized: "empty.no_results.description"),
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
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowInsets(
                        .init(top: 8, leading: 0, bottom: 8, trailing: 0)
                    )
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            onAction(.onRemoveItem(item))
                        } label: {
                            Label(String(localized: "swipe_action.delete"), systemImage: "trash")
                                .tint(AppColors.destructive)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(String(localized: "navigation.lists"))
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: String(localized: "placeholder.search_lists")
        )
        .toolbar {

            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    onAction(.onSettingsTap)
                }) {
                    Image(systemName: "gearshape")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    onAction(.onAddTap)
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(String(localized: "accessibility.new_list"))
            }
        }
        .sheet(
            isPresented: Binding(
                get: {
                    presentation == .addList
                },
                set: { isPresented in
                    if !isPresented {
                        presentation = nil
                    }
                }
            )
        ) {
            NavigationStack {
                AddListView(
                    onSubmit: {
                        title in
                        onAction(.onAddItem(title))
                    }
                )
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
            searchText: .constant(""),
            selectedFilter: .constant(.active),
            presentation: .constant(nil),
            onAction: { _ in }
        )
    }
}
