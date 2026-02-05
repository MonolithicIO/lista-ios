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

        func toDomainModel() -> ListState {
            switch self {
            case .active:
                return .active
            case .completed:
                return .completed
            case .archived:
                return .archived
            }
        }
    }

    enum Presentation {
        case addList
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
        @Published var filter: Filter = .active
        @Published var searchQuery: String = ""

        func onAppear() {
            Task {
                await fetchLists()
            }
        }

        func addList(title: String) {
            Task {
                do {
                    let newList = try await createListService.create(
                        title: title
                    )
                    items.append(
                        ListaUiModel(
                            id: newList.id.uuidString,
                            title: newList.title,
                            itemCount: newList.itemCount,
                            completedCount: newList.completedCount
                        )
                    )
                } catch {

                }
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

        func onChangeSearchQuery() {
            Task {
                await fetchLists()
            }
        }

        private func fetchLists() async {
            do {
                items = try await fetchListsService.fetch(
                    filter: FetchListFilter(
                        query: self.searchQuery,
                        state: self.filter.toDomainModel()
                    )
                ).map { domainModel in
                    domainModel.toUiModel()
                }
            } catch {

            }
        }
    }
}
