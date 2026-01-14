//
//  HomeContentView.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI

struct HomeContentView: View {
    @Environment(NavigationCoordinator.self) private var coordinator: NavigationCoordinator
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Hello")
        }
        .background(AppColors.background)
        .navigationTitle("Home")
        .toolbar {
            Button(action: {
                coordinator.push(.setings)
            }) {
                Image(systemName: "gearshape")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        }
        .task {
            
        }
    }
}

#Preview {
    NavigationView {
        HomeContentView()
    }
}
