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
    private let audioRecorder: AudioRecorderProtocol
    private let audioPlayer: AudioPlayerProtocol

    // MARK: - Initializer
    init(
        createItemService: CreateListItemServiceProtocol,
        getItemService: GetListItemServiceProtocol,
        updateListItemService: UpdateListItemServiceProtocol,
        audioRecorder: AudioRecorderProtocol,
        audioPlayer: AudioPlayerProtocol
    ) {
        self.createItemService = createItemService
        self.getItemService = getItemService
        self.updateListItemService = updateListItemService
        self.audioRecorder = audioRecorder
        self.audioPlayer = audioPlayer
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
    @Published var isAudioPlaying: Bool = false
    @Published var audioPlaybackProgress: Double = 0
    @Published var audioPermissionDenied: Bool = false

    var shouldShowAudioSection: Bool {
        true
    }

    // MARK: - Private State
    private var originalItem: ListaItemUiModel?
    private var audioDraftURL: URL?
    private var playbackObserver: AnyCancellable?

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
        audioPlayer.stop()
        stopPlaybackObserver(resetProgress: true)
        isAudioPlaying = false

        Task {
            let isGranted = await audioRecorder.requestRecordPermission()

            await MainActor.run {
                self.audioPermissionDenied = !isGranted
            }

            guard isGranted else { return }

            do {
                try audioRecorder.startRecording()
                await MainActor.run {
                    self.isAudioRecording = true
                    self.hasAudioDraft = false
                    self.isAudioPlaying = false
                    self.audioPlaybackProgress = 0
                    self.audioDraftURL = nil
                }
            } catch {
                let error = error
                print(error)
                await MainActor.run {
                    self.isAudioRecording = false
                }
            }
        }
    }

    func stopAudioRecording() {
        do {
            let draftURL = try audioRecorder.stopRecording()
            isAudioRecording = false
            hasAudioDraft = true
            isAudioPlaying = false
            audioPlaybackProgress = 0
            audioDraftURL = draftURL
        } catch {
            isAudioRecording = false
            hasAudioDraft = audioRecorder.hasDraft

            if !hasAudioDraft {
                isAudioPlaying = false
                audioPlaybackProgress = 0
                audioDraftURL = nil
            }
        }
    }

    func toggleAudioPlayback() {
        syncPlaybackState()

        if isAudioPlaying != audioPlayer.isPlaying {
            isAudioPlaying = audioPlayer.isPlaying
        }

        if isAudioPlaying {
            audioPlayer.pause()
            isAudioPlaying = false
            stopPlaybackObserver(resetProgress: false)
            syncPlaybackState()
            return
        }

        guard let audioDraftURL else { return }

        do {
            try audioPlayer.play(url: audioDraftURL)
            isAudioPlaying = true
            startPlaybackObserver()
            syncPlaybackState()
        } catch {
            isAudioPlaying = false
        }
    }

    func discardAudioDraftIfNeeded() {
        audioPlayer.stop()
        stopPlaybackObserver(resetProgress: true)

        do {
            try audioRecorder.discardDraft()
        } catch {
            // no-op
        }

        isAudioRecording = false
        hasAudioDraft = false
        isAudioPlaying = false
        audioPlaybackProgress = 0
        audioDraftURL = nil
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

    private func startPlaybackObserver() {
        stopPlaybackObserver(resetProgress: false)

        playbackObserver = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.syncPlaybackState()
            }
    }

    private func stopPlaybackObserver(resetProgress: Bool) {
        playbackObserver?.cancel()
        playbackObserver = nil

        if resetProgress {
            audioPlaybackProgress = 0
        }
    }

    private func syncPlaybackState() {
        let duration = audioPlayer.duration
        let currentTime = audioPlayer.currentTime

        if duration > 0 {
            let progress = currentTime / duration
            audioPlaybackProgress = min(max(progress, 0), 1)
        } else {
            audioPlaybackProgress = 0
        }

        if isAudioPlaying && !audioPlayer.isPlaying {
            isAudioPlaying = false
            stopPlaybackObserver(resetProgress: false)
        }
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
        self.isAudioPlaying = false
        self.audioPlaybackProgress = 0
        self.audioPermissionDenied = false
        self.audioDraftURL = nil
        self.stopPlaybackObserver(resetProgress: true)
    }

}

extension InsertItemViewModel {
    enum Events {
        case onSuccess
    }
}
