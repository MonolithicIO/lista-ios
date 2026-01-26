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
        private let createItemService: CreateListItemServiceProtocol
        private let updateItemStatusService: UpdateItemStatusServiceProtocol
        private let deleteListService: RemoveListServiceProtocol

        @Published private(set) var items: [ListaItemUiModel] = []

        init(
            fetchDetailsService: FetchListaDetailsServiceProtocol,
            createItemService: CreateListItemServiceProtocol,
            updateItemStatusService: UpdateItemStatusServiceProtocol,
            deleteListService: RemoveListServiceProtocol
        ) {
            self.fetchDetailsService = fetchDetailsService
            self.createItemService = createItemService
            self.updateItemStatusService = updateItemStatusService
            self.deleteListService = deleteListService
        }

        func onAppear(listaId: String) async {
            guard let uuid = UUID(uuidString: listaId) else { return }
            do {
                let details = try await fetchDetailsService.fetch(listaId: uuid)
                items = details.items.map { item in
                    item.toUiModel()
                }
            } catch {
                items = []
            }
        }

        func onAddNewItem(item: AddListaItemUiModel, listaId: String) async {
            guard let listaUuid = UUID(uuidString: listaId) else { return }

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
            } catch {
                print("Error saving new item \(error)")
            }
        }

        func onToogleItemState(item: ListaItemUiModel) async {
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
            } catch {
                print("Error updating item \(item.id). Error: \(error) ")
            }
        }
        
        func onDeleteList(listaId: String) async -> Void {
            do {
                try await deleteListService.remove(listId: listaId)
            } catch {
                print("Error deleting list: \(listaId). Error: \(error)")
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
