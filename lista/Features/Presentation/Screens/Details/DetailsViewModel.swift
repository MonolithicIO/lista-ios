//
//  DetailsViewModel.swift
//  lista
//
//  Created by Lucca Beurmann on 21/01/26.
//

import Combine
import Foundation

extension DetailsScreen {

    @MainActor
    final class ViewModel: ObservableObject {

        init() {

        }

        @Published private(set) var items: [ListaItemUiModel] = []

    }
}
