//
//  InsertItemViewModel.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Combine
import Foundation

final class InsertItemViewModel: ObservableObject {
    // MARK: - Dependency properties
    private let createItemService: CreateListItemServiceProtocol

    // MARK: - Initializer
    init(createItemService: CreateListItemServiceProtocol) {
        self.createItemService = createItemService
    }

    // MARK: - State properties
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var url: String = ""
    @Published var isEditing: Bool = false
    @Published var event: Events? = nil

    func initialize(itemId: String?) {
        isEditing = itemId != nil
    }

    func insertItem(listId: String) {
        guard let uuid = UUID(uuidString: listId) else { return }
        Task {
            do {
                _ = try await createItemService.create(
                    item: CreateListItemDTO(
                        listId: uuid,
                        title: self.title,
                        description: sanitizeString(input: self.description),
                        url: sanitizeString(input: self.url),
                        image: nil
                    )
                )
                event = .onSuccess

            } catch {
                print("Failed to create item \(error)")
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

extension InsertItemViewModel {
    enum Events {
        case onSuccess
    }
}
