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
                coordinator.push(.setings)
            }
        )
    }
}

private struct HomeScreenView: View {
    let list: [ListUiModel]
    let onSettingsClick: () -> Void
    var isEmpty: Bool { list.isEmpty }

    var body: some View {
        VStack(spacing: 16) {
            ListsView(items: list)
        }
        .background(AppColors.background)
        .navigationTitle("Home")
        .toolbar {
            Button(action: {
                onSettingsClick()
            }) {
                Image(systemName: "gearshape")
                    .resizable()
                    .frame(width: 30, height: 30)
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
