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
    @State private var presentation: Presentation? = nil

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
                }
            }
        ).task {
            await viewModel.onAppear()
        }

    }
}

extension HomeScreenView {
    enum Actions {
        case onSettingsTap
        case onAddTap
        case onAddItem(String)
        case onItemTap(ListaUiModel)
    }
}

private struct HomeScreenView: View {
    let items: [ListaUiModel]
    @Binding var searchText: String
    @Binding var selectedFilter: HomeScreen.Filter
    @Binding var presentation: HomeScreen.Presentation?
    let onAction: (Actions) -> Void

    var body: some View {
        Group {
            if items.isEmpty {
                EmptyStateView(
                    title: "No lists created",
                    description:
                        "Create your first list and start tracking your tasks!",
                    iconName: "list.bullet",
                    actionTitle: "Create list",
                    onAction: {
                        onAction(.onAddTap)
                    }
                )
            } else {
                List(items) { item in
                    Button {
                        onAction(.onItemTap(item))
                    } label: {
                        ListaCardView(item: item)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(
                        .init(top: 6, leading: 0, bottom: 6, trailing: 0)
                    )
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColors.card)
                    )
                }
                .listStyle(.plain)
                .listRowSpacing(12)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Lists")
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search lists"
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
                .accessibilityLabel("New lsit")
            }

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
        .sheet(isPresented: .constant(presentation == .addList)) {
            NavigationStack {
                AddListView(
                    onDismiss: {
                        presentation = nil
                    },
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
                ListaUiModel(id: "123", title: "Presentes de natal"),
                ListaUiModel(id: "321", title: "Presentes de natal"),
            ],
            searchText: .constant(""),
            selectedFilter: .constant(.active),
            presentation: .constant(nil),
            onAction: { _ in }
        )
    }
}
