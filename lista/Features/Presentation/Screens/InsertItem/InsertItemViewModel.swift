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

@MainActor
final class InsertItemViewModel: ObservableObject {
    // MARK: - Dependency properties
    private let createItemService: CreateListItemServiceProtocol
    private let getItemService: GetListItemServiceProtocol
    private let updateListItemService: UpdateListItemServiceProtocol
    private let audioManager: AudioManagerProtocol

    // MARK: - Initializer
    init(
        createItemService: CreateListItemServiceProtocol,
        getItemService: GetListItemServiceProtocol,
        updateListItemService: UpdateListItemServiceProtocol,
        audioManager: AudioManagerProtocol
    ) {
        self.createItemService = createItemService
        self.getItemService = getItemService
        self.updateListItemService = updateListItemService
        self.audioManager = audioManager
    }

    // MARK: - Public State
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var url: String = ""
    @Published var isCompleted: Bool = false
    @Published var selectedImage: UIImage?
    @Published var isEditing: Bool = false
    @Published var event: Events? = nil
    @Published var galleryPickerSelection: PhotosPickerItem?
    @Published var isAddMoreEnabled: Bool = false
    @Published var isAudioRecording: Bool = false
    @Published var hasAudioDraft: Bool = false
    @Published var audioPermissionDenied: Bool = false

    var shouldShowAudioSection: Bool {
        true
    }

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

        if isEditing {
            guard let originalItemId = originalItem?.id else { return }
            guard let originalItemUuid = UUID(uuidString: originalItemId) else { return }
            
            updateItem(itemId: originalItemUuid)
        } else {
            createNewItem(listId: uuid)
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

    func startAudioRecording() {
        Task {
            let isGranted = await audioManager.requestRecordPermission()

            await MainActor.run {
                self.audioPermissionDenied = !isGranted
            }

            guard isGranted else { return }

            do {
                try audioManager.startRecording()
                await MainActor.run {
                    self.isAudioRecording = true
                    self.hasAudioDraft = false
                }
            } catch {
                await MainActor.run {
                    self.isAudioRecording = false
                }
            }
        }
    }

    func stopAudioRecording() {
        do {
            _ = try audioManager.stopRecording()
            isAudioRecording = false
            hasAudioDraft = true
        } catch {
            isAudioRecording = false
            hasAudioDraft = audioManager.hasDraft
        }
    }

    func discardAudioDraftIfNeeded() {
        do {
            try audioManager.discardDraft()
        } catch {
            // no-op
        }

        isAudioRecording = false
        hasAudioDraft = false
    }

    func dismissAudioPermissionAlert() {
        audioPermissionDenied = false
    }

    private func createNewItem(listId: UUID) {
        Task {
            do {
                _ = try await createItemService.create(
                    item: CreateListItemDTO(
                        listId: listId,
                        title: self.title,
                        description: sanitizeString(input: self.description),
                        url: sanitizeString(input: self.url),
                        image: self.selectedImage
                    )
                )
                
                if isAddMoreEnabled {
                    discardAudioDraftIfNeeded()
                    clearState()
                } else {
                    discardAudioDraftIfNeeded()
                    event = .onSuccess
                }
            } catch {
                print("Failed to create item \(error)")
            }
        }
    }

    private func updateItem(
        itemId: UUID,
    ) {
        Task {
            do {
                _ = try await updateListItemService.update(
                    item: UpdateListItemDTO(
                        itemId: itemId,
                        title: self.title,
                        description: sanitizeString(input: self.description),
                        url: sanitizeString(input: self.url),
                        isCompleted: self.isCompleted,
                        image: self.selectedImage,
                        shouldRemoveImage: false
                    )
                )
                discardAudioDraftIfNeeded()
                event = .onSuccess

            } catch {
                print("Failed to create item \(error)")
            }
        }
    }

    private func loadItemData(itemId: String) {
        Task {
            do {
                let item = try await getItemService.get(id: itemId)

                await MainActor.run {
                    title = item.title
                    description = item.description ?? ""
                    url = item.url ?? ""
                    isCompleted = item.isCompleted
                    originalItem = item.toUiModel()
                }
                
                // Load image asynchronously on background thread
                if let imagePath = item.imageUrl {
                    let image = await Task.detached {
                        UIImage(contentsOfFile: imagePath)
                    }.value
                    await MainActor.run {
                        selectedImage = image
                    }
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
    
    private func clearState() {
        self.title = ""
        self.description = ""
        self.url = ""
        self.isCompleted = false
        self.selectedImage = nil
        self.event = nil
        self.galleryPickerSelection = nil
        self.isAudioRecording = false
        self.hasAudioDraft = false
        self.audioPermissionDenied = false
    }

}

extension InsertItemViewModel {
    enum Events {
        case onSuccess
    }
}
