//
//  HomeViewModel.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import Combine
import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    private let fetchListsService: FetchListsServiceProtocol
    private let createListService: CreateListServiceProtocol
    private let removeListService: RemoveListServiceProtocol
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    init(
        fetchListsService: FetchListsServiceProtocol,
        createListService: CreateListServiceProtocol,
        removeListService: RemoveListServiceProtocol
    ) {
        self.fetchListsService = fetchListsService
        self.createListService = createListService
        self.removeListService = removeListService
        
        // Setup debounced search
        setupSearchDebouncing()
    }

    @Published private(set) var items: [ListaUiModel] = []
    @Published var filter: HomeFilter = .active
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
                        completedCount: newList.completedCount,
                        status: newList.toStatus()
                    )
                )
            } catch {

            }
        }
    }

    func removeList(list _removedItem: ListaUiModel) {
        Task {
            do {
                try await removeListService.remove(listId: _removedItem.id)
                items = items.filter { list in
                    list.id != _removedItem.id
                }
            } catch {

            }
        }
    }

    func onChangeSearchQuery() {
        // Debounced search is handled by Combine publisher
    }

    private func setupSearchDebouncing() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task {
                    await self?.fetchLists()
                }
            }
            .store(in: &cancellables)
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
