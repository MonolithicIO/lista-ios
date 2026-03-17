//
//  DetailsViewModel.swift
//  lista
//
//  Created by Lucca Beurmann on 23/01/26.
//

import Combine
import Foundation

@MainActor
@Observable
class DetailsViewModel {
    private let fetchDetailsService: FetchListaDetailsServiceProtocol
    private let deleteListService: RemoveListServiceProtocol
    private let archiveListService: ArchiveListServiceProtocol
    private let createItemService: CreateListItemServiceProtocol
    private let updateItemStatusService: UpdateItemStatusServiceProtocol
    private let updateItemService: UpdateListItemServiceProtocol
    private let completeListService: CompleteListServiceProtocol
    private let revertCompleteListService: RevertCompleteServiceProtocol
    private let dateProvider: DateProviderProtocol
    private let deleteItemService: DeleteListItemServiceProtocol

    private(set) var items: [ListaItemUiModel] = []
    private(set) var isArchived: Bool = false
    private(set) var isCompleted: Bool = false
    private(set) var updatedAt: Date? = nil
    private(set) var events: Events? = nil
    var canEdit: Bool {
        return !isArchived && !isCompleted

    }
    private var listId: String!

    init(
        fetchDetailsService: FetchListaDetailsServiceProtocol,
        createItemService: CreateListItemServiceProtocol,
        updateItemStatusService: UpdateItemStatusServiceProtocol,
        deleteListService: RemoveListServiceProtocol,
        archiveListService: ArchiveListServiceProtocol,
        dateProvider: DateProviderProtocol,
        completeListService: CompleteListServiceProtocol,
        revertCompleteListService: RevertCompleteServiceProtocol,
        updateItemService: UpdateListItemServiceProtocol,
        deleteItemService: DeleteListItemServiceProtocol
    ) {
        self.fetchDetailsService = fetchDetailsService
        self.createItemService = createItemService
        self.updateItemStatusService = updateItemStatusService
        self.deleteListService = deleteListService
        self.archiveListService = archiveListService
        self.dateProvider = dateProvider
        self.completeListService = completeListService
        self.revertCompleteListService = revertCompleteListService
        self.updateItemService = updateItemService
        self.deleteItemService = deleteItemService
    }

    func onAppear(listaId: String) {
        self.listId = listaId
        loadList()
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
                        url: self.sanitizeString(input: item.url),
                        image: item.attachedImage
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

                let updatedItem =
                    try await updateItemStatusService.updateItemStatus(
                        itemId: item.id,
                        isCompleted: newState
                    )

                items[itemIndex] = updatedItem.toUiModel()
                updatedAt = updatedItem.updatedAt
            } catch {
                print("Error updating item \(item.id). Error: \(error) ")
            }
        }

    }

    func onDeleteList() {
        Task {
            do {
                try await deleteListService.remove(listId: listId)
                events = .deleteSuccess
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
                try await archiveListService.archive(
                    listaId: listId,
                    isArchived: state
                )
                self.isArchived = state
                self.updatedAt = try dateProvider.currentDate()
            } catch {
                print(
                    "Error updating archived list state: \(listId ?? ""). Error: \(error)"
                )
            }
        }
    }

    func setCompletedState(state: Bool) {
        Task {
            do {
                if state {
                    try await completeListService.complete(listaId: listId)
                } else {
                    try await revertCompleteListService.revert(
                        listaId: listId
                    )
                }

                loadList()
            } catch {
                print(
                    "Error updating archived list state: \(listId ?? ""). Error: \(error)"
                )
            }
        }
    }

    func onUpdateItem(dto: UpdateListItemDTO) {
        Task {
            do {
                let updatedItem = try await updateItemService.update(item: dto)

                // Find and update the item in the local array
                if let index = items.firstIndex(where: {
                    $0.id == updatedItem.id.uuidString
                }) {
                    items[index] = updatedItem.toUiModel()
                    updatedAt = updatedItem.updatedAt
                }
            } catch {
                print("Error updating item: \(dto.itemId). Error: \(error)")
            }
        }
    }

    func onDeleteItem(itemId: String) {
        Task {
            do {
                try await deleteItemService.deleteItem(itemId: itemId)

                // Remove item from local array
                items.removeAll { $0.id == itemId }
                updatedAt = try dateProvider.currentDate()
            } catch {
                print("Error deleting item: \(itemId). Error: \(error)")
            }
        }
    }

    private func loadList() {
        Task {
            guard let uuid = UUID(uuidString: self.listId) else { return }
            do {
                let details = try await fetchDetailsService.fetch(
                    listaId: uuid
                )
                items = details.items.map { item in
                    item.toUiModel()
                }
                isArchived = details.isArchived
                isCompleted = details.isCompleted
                listId = details.id.uuidString
                updatedAt = details.updatedAt
            } catch {
                items = []
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

extension DetailsViewModel {
    enum Events: Equatable {
        case deleteSuccess
    }
}
