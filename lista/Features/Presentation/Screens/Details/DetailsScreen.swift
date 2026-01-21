//
//  DetailsContentView.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI

struct DetailsScreen: View {
    @Environment(NavigationCoordinator.self) private var coordinator:
        NavigationCoordinator
    let listaId: String
    let listaTitle: String

    var body: some View {
        DetailsScreenView(
            title: listaTitle,
            onBack: {

            }
        )
    }
}

private struct DetailsScreenView: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        VStack {

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(
                        systemName: "chevron.left"
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
            onBack: {}
        )
    }
}
