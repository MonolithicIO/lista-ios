//
//  InsertItemViewModel.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Combine
import Foundation
import PhotosUI
import SwiftUI

final class InsertItemViewModel: ObservableObject {
    // MARK: - Dependency properties
    private let createItemService: CreateListItemServiceProtocol
    private let getItemService: GetListItemServiceProtocol
    private let updateListItemService: UpdateListItemServiceProtocol

    // MARK: - Initializer
    init(
        createItemService: CreateListItemServiceProtocol,
        getItemService: GetListItemServiceProtocol,
        updateListItemService: UpdateListItemServiceProtocol
    ) {
        self.createItemService = createItemService
        self.getItemService = getItemService
        self.updateListItemService = updateListItemService
    }

    // MARK: - Public State
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var url: String = ""
    @Published var isEditing: Bool = false
    @Published var selectedImage: UIImage?
    @Published var event: Events? = nil
    @Published var galleryPickerSelection: PhotosPickerItem?
    
    // MARK: - Private State
    private var originalItem: ListaItemUiModel?

    func initialize(itemId: String?) {
        if let itemId {
            loadItemData(itemId: itemId)
            isEditing = true
        }
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
                        image: self.selectedImage
                    )
                )
                event = .onSuccess

            } catch {
                print("Failed to create item \(error)")
            }
        }
    }

    func handleGallerySelection(_ item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            {
                await MainActor.run {
                    self.selectedImage = image
                    self.galleryPickerSelection = nil
                }
            }
        }
    }
    
    private func loadItemData(itemId: String) {
        Task {
            do {
                let item = try await getItemService.get(id: itemId)
                
                title = item.title
                description = item.description ?? ""
                url = item.url ?? ""
                originalItem = item.toUiModel()
                if let imagePath = item.imageUrl {
                    selectedImage = UIImage(contentsOfFile: imagePath)
                }
            } catch {
                print("Failed to fetch item details \(error)")
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
