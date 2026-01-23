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

        func onAddNewItem(item: AddListaItemUiModel, listaId: String) async {
            guard let listaUuid = UUID(uuidString: listaId) else { return }

            do {
                let newItem = try await createItemService.create(
                    item: CreateListItemDTO(
                        listId: listaUuid,
                        title: item.title.trimmingCharacters(in: .whitespacesAndNewlines),
                        description: self.sanitizeString(input: item.description),
                        url: self.sanitizeString(input: item.url)
                    )
                )
                items.append(newItem.toUiModel())
            } catch {
                print("Error saving data \(error)")
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
