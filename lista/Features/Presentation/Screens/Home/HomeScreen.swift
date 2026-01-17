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
            }
        ).task {
            await viewModel.onAppear()
        }
    }
}

private struct HomeScreenView: View {
    let list: [ListUiModel]
    let onSettingsClick: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ListsView(items: list)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem {
                Button(action: onSettingsClick) {
                    Image(systemName: "gearshape")
                        .font(.title3)
                }
            }
        }
    }
}



#Preview {
    NavigationStack {
        HomeScreenView(
            list: [
                ListUiModel(id: "123", title: "Presentes de natal"),
                ListUiModel(id: "321", title: "Presentes de natal"),
            ],
            onSettingsClick: {}
        )
    }
}
