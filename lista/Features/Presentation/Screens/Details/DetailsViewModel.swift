//
//  DetailsViewModel.swift
//  lista
//
//  Created by Lucca Beurmann on 23/01/26.
//

import Combine
import Foundation

extension DetailsScreen {

    @MainActor
    class ViewModel: ObservableObject {
        private let fetchDetailsService: FetchListaDetailsServiceProtocol
        private let deleteListService: RemoveListServiceProtocol
        private let archiveListService: ArchiveListServiceProtocol
        private let createItemService: CreateListItemServiceProtocol
        private let updateItemStatusService: UpdateItemStatusServiceProtocol
        private let dateProvider: DateProviderProtocol

        @Published private(set) var items: [ListaItemUiModel] = []
        @Published private(set) var isArchived: Bool = false
        @Published private(set) var updatedAt: Date? = nil
        private var listId: String!

        init(
            fetchDetailsService: FetchListaDetailsServiceProtocol,
            createItemService: CreateListItemServiceProtocol,
            updateItemStatusService: UpdateItemStatusServiceProtocol,
            deleteListService: RemoveListServiceProtocol,
            archiveListService: ArchiveListServiceProtocol,
            dateProvider: DateProviderProtocol
        ) {
            self.fetchDetailsService = fetchDetailsService
            self.createItemService = createItemService
            self.updateItemStatusService = updateItemStatusService
            self.deleteListService = deleteListService
            self.archiveListService = archiveListService
            self.dateProvider = dateProvider
        }

        func onAppear(listaId: String) {
            Task {
                guard let uuid = UUID(uuidString: listaId) else { return }
                do {
                    let details = try await fetchDetailsService.fetch(
                        listaId: uuid
                    )
                    items = details.items.map { item in
                        item.toUiModel()
                    }
                    isArchived = details.isArchived
                    listId = details.id.uuidString
                    updatedAt = details.updatedAt
                } catch {
                    items = []
                }
            }
        }

        func onAddNewItem(item: AddListaItemUiModel) {
            Task {
                guard let listaUuid = UUID(uuidString: listId) else { return }

                do {
                    let newItem = try await createItemService.create(
                        item: CreateListItemDTO(
                            listId: listaUuid,
                            title: item.title.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ),
                            description: self.sanitizeString(
                                input: item.description
                            ),
                            url: self.sanitizeString(input: item.url)
                        )
                    )
                    items.append(newItem.toUiModel())
                    updatedAt = try dateProvider.currentDate()
                } catch {
                    print("Error saving new item \(error)")
                }
            }
        }

        func onToogleItemState(item: ListaItemUiModel) {
            Task {
                guard
                    let itemIndex = items.firstIndex(
                        where: { stateItem in
                            item.id == stateItem.id
                        }
                    )
                else {
                    return
                }

                do {
                    let newState = !item.isCompleted

                    try await updateItemStatusService.updateItemStatus(
                        itemId: item.id,
                        isCompleted: newState
                    )

                    let item = items[itemIndex]

                    items[itemIndex] = ListaItemUiModel(
                        listId: item.listId,
                        id: item.id,
                        title: item.title,
                        description: item.description,
                        url: item.url,
                        isCompleted: newState
                    )
                    updatedAt = try dateProvider.currentDate()
                } catch {
                    print("Error updating item \(item.id). Error: \(error) ")
                }
            }

        }

        func onDeleteList() {
            Task {
                do {
                    try await deleteListService.remove(listId: listId)
                } catch {
                    print(
                        "Error deleting list: \(listId ?? ""). Error: \(error)"
                    )
                }
            }

        }

        func setArchiveState(state: Bool) {
            Task {
                do {
                    let newState = !self.isArchived
                    try await archiveListService.archive(
                        listaId: listId,
                        isArchived: newState
                    )
                    self.isArchived = newState
                    self.updatedAt = try dateProvider.currentDate()
                } catch {
                    print(
                        "Error updating archived list state: \(listId ?? ""). Error: \(error)"
                    )
                }
            }
        }

        private func sanitizeString(input: String?) -> String? {
            guard let filledInput = input else { return nil }

            if filledInput.isEmpty {
                return nil
            }

            return filledInput.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
