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

        @Published private(set) var items: [ListaItemUiModel] = []

        init(
            fetchDetailsService: FetchListaDetailsServiceProtocol,
            createItemService: CreateListItemServiceProtocol
        ) {
            self.fetchDetailsService = fetchDetailsService
            self.createItemService = createItemService
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

        func onAddNewItem(title: String, listaId: String) async throws {
            guard let listaUuid = UUID(uuidString: listaId) else { return }

            let newItem = try await createItemService.create(
                item: CreateListItemDTO(
                    listId: listaUuid,
                    title: title,
                    description: nil,
                    url: nil
                )
            )
            items.append(newItem.toUiModel())
        }
    }
}
