//
//  HomeViewModel.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import Foundation
import SwiftUI

extension HomeScreen {

    @Observable
    class ViewModel {
        private let fetchListsService: FetchListsServiceProtocol
        private let createListService: CreateListServiceProtocol
        private let removeListService: RemoveListServiceProtocol

        init(
            fetchListsService: FetchListsServiceProtocol,
            createListService: CreateListServiceProtocol,
            removeListService: RemoveListServiceProtocol
        ) {
            self.fetchListsService = fetchListsService
            self.createListService = createListService
            self.removeListService = removeListService
        }

        private(set) var items: [ListUiModel] = []
    }
}
