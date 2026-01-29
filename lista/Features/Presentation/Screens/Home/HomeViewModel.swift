//
//  HomeViewModel.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import Combine
import Foundation

extension HomeScreen {
    
    enum Filter: String, CaseIterable, Identifiable {
        case active = "Active"
        case completed = "Completed"
        case archived = "Archived"

        var id: String { rawValue }
    }

    @MainActor
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

        @Published private(set) var items: [ListaUiModel] = []

        func onAppear() async {
            do {
                items = try await fetchListsService.fetch().map { domainModel in
                    ListaUiModel(
                        id: domainModel.id.uuidString,
                        title: domainModel.title
                    )
                }
            } catch {

            }
        }

        func addList(title: String) async {
            do {
                let newList = try await createListService.create(title: title)
                items.append(
                    ListaUiModel(
                        id: newList.id.uuidString,
                        title: newList.title
                    )
                )
            } catch {

            }
        }

        func removeList(list _removedItem: ListaUiModel) async {
            do {
                try await removeListService.remove(listId: _removedItem.id)
                items = items.filter { list in
                    list.id != _removedItem.id
                }
            } catch {

            }

        }
    }
}
