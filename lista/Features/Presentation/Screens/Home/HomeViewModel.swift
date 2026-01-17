//
//  HomeViewModel.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import Combine
import Foundation
import SwiftUI

extension HomeScreen {

    class ViewModel: ObservableObject {
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

        @Published private(set) var items: [ListUiModel] = []

        func onAppear() async {
            items = await fetchListsService.fetch().map { domainModel in
                ListUiModel(
                    id: domainModel.id.uuidString,
                    title: domainModel.title
                )
            }
        }

        func addList(title: String) async {
            let newList = await createListService.create(title: title)
            items.append(
                ListUiModel(id: newList.id.uuidString, title: newList.title)
            )
        }
        
        func removeList(list: ListUiModel) async {
            guard let listUuid = UUID(uuidString: list.id) else {
                return
            }
            await removeListService.remove(id: listUuid)
            items = items.filter { list in
                list.id != list.id
            }
        }
    }
}
