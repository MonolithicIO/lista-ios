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
            list: viewModel.items,
            onSettingsClick: {
                coordinator.push(.settings)
            },
            onTapNewList: {
                isPresentingNewList = true
            },
            onAddNewList: { newTitle in
                Task {
                    isPresentingNewList = false
                    await viewModel.addList(title: newTitle)
                }
            },
            onDetailsClick: { item in
                coordinator.push(
                    .details(listaId: item.id, listaTitle: item.title)
                )
            },
            isPresentingNewList: $isPresentingNewList
        ).task {
            await viewModel.onAppear()
        }
    }
}

private struct HomeScreenView: View {
    let list: [ListaUiModel]
    let onSettingsClick: () -> Void
    let onTapNewList: () -> Void
    let onAddNewList: (String) -> Void
    let onDetailsClick: (ListaUiModel) -> Void
    @Binding var isPresentingNewList: Bool

    var body: some View {
        VStack(spacing: 16) {
            ListsView(
                items: list,
                onItemTap: onDetailsClick
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onSettingsClick) {
                    Image(systemName: "gearshape")
                        .foregroundStyle(AppColors.foreground)
                        .accessibilityLabel("Settings")
                        .font(.title3)
                }
            }
        }
        .sheet(
            isPresented: $isPresentingNewList,
            content: {
                NavigationStack {
                    AddListView { newTitle in
                        onAddNewList(newTitle)
                    }
                    .presentationDragIndicator(.visible)
                }
            }
        )
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button(action: onTapNewList) {
                    Image(systemName: "plus")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppColors.background)
                        .frame(width: 56, height: 56)
                        .background(AppColors.foreground)
                        .clipShape(.circle)
                }
                .shadow(radius: 8)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }
}

#Preview {
    NavigationStack {
        HomeScreenView(
            list: [
                ListaUiModel(id: "123", title: "Presentes de natal"),
                ListaUiModel(id: "321", title: "Presentes de natal"),
            ],
            onSettingsClick: {},
            onTapNewList: {},
            onAddNewList: { value in
            },
            onDetailsClick: { item in
            },
            isPresentingNewList: .constant(false)
        )
    }
}
