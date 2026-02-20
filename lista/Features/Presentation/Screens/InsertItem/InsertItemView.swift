//
//  InsertItemView.swift
//  lista
//
//  Redesigned with modern card-based layout
//

import Foundation
import PhotosUI
import SwiftUI

struct InsertItemView: View {
    // MARK: - Env
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @StateObject var viewModel: InsertItemViewModel
    @State var presentedImagePicker: PresentedImagePicker? = nil

    // MARK: - Input properties
    let listId: String
    let itemId: String?

    init(
        listId: String,
        itemId: String?,
        viewModel: InsertItemViewModel =
            InstanceKeeper.shared.provideInsertItemViewModel()
    ) {
        self.listId = listId
        self.itemId = itemId
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var screenTitle: String {
        if itemId != nil {
            String(localized: "navigation.edit_item")
        } else {
            String(localized: "navigation.create_item")
        }
    }

    var body: some View {
        InsertItemContentView(
            isEditing: self.viewModel.isEditing,
            onAction: { action in
                switch action {

                case .onSubmit:
                    self.viewModel.insertItem(listId: self.listId)
                case .onStartAudioRecording:
                    self.viewModel.startAudioRecording()
                case .onStopAudioRecording:
                    self.viewModel.stopAudioRecording()
                case .onDiscardAudioDraft:
                    self.viewModel.discardAudioDraftIfNeeded()
                case .onToggleAudioPlayback:
                    self.viewModel.toggleAudioPlayback()
                }
            },
            presentedImagePicker: self.$presentedImagePicker,
            itemTitle: self.$viewModel.title,
            itemDescription: self.$viewModel.description,
            itemUrl: self.$viewModel.url,
            selectedImage: self.$viewModel.selectedImage,
            isAddMoreEnabled: self.$viewModel.isAddMoreEnabled,
            isAudioRecording: self.$viewModel.isAudioRecording,
            hasAudioDraft: self.$viewModel.hasAudioDraft,
            isAudioPlaying: self.$viewModel.isAudioPlaying,
            audioPlaybackProgress: self.$viewModel.audioPlaybackProgress
        )
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.background)
        .navigationTitle(screenTitle)
        .task {
            viewModel.initialize(itemId: itemId)
        }
        .onChange(of: viewModel.event) { _, newValue in
            guard let event = newValue else { return }
            switch event {

            case .onSuccess:
                dismiss()
            }
        }
        .onDisappear {
            viewModel.discardAudioDraftIfNeeded()
        }
        .alert(String(localized: "alert.microphone_access_needed.title"), isPresented: $viewModel.audioPermissionDenied) {
            Button(String(localized: "button.ok")) {
                viewModel.dismissAudioPermissionAlert()
            }
        } message: {
            Text(String(localized: "alert.microphone_access_needed.message"))
        }
        // MARK: - Gallery Picker
        .photosPicker(
            isPresented: Binding(
                get: { presentedImagePicker == .gallery },
                set: { isPresented in
                    if !isPresented {
                        presentedImagePicker = nil
                    }
                }
            ),
            selection: $viewModel.galleryPickerSelection,
            matching: .images
        )
        .onChange(of: viewModel.galleryPickerSelection) { _, newValue in
            self.viewModel.handleGallerySelection(newValue)
        }
        // MARK: - Camera Picker
        .sheet(
            isPresented: Binding(
                get: { presentedImagePicker == .camera },
                set: { isPresented in
                    if !isPresented {
                        presentedImagePicker = nil
                    }
                }
            )
        ) {
            CameraPickerView(
                onImagePicked: { uiImage in
                    viewModel.selectedImage = uiImage
                    presentedImagePicker = nil
                }
            )
            .ignoresSafeArea()
        }
    }
}

extension InsertItemView {
    enum PresentedImagePicker {
        case gallery
        case camera
    }
}

struct InsertItemContentView: View {
    let isEditing: Bool
    let onAction: (Action) -> Void

    @Binding var presentedImagePicker: InsertItemView.PresentedImagePicker?
    @Binding var itemTitle: String
    @Binding var itemDescription: String
    @Binding var itemUrl: String
    @Binding var selectedImage: UIImage?
    @Binding var isAddMoreEnabled: Bool
    @Binding var isAudioRecording: Bool
    @Binding var hasAudioDraft: Bool
    @Binding var isAudioPlaying: Bool
    @Binding var audioPlaybackProgress: Double

    var isButtonEnabled: Bool {
        return !itemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader(
                    title: String(localized: "section.title"),
                    isOptional: false
                )
                titleCard

                sectionHeader(
                    title: String(localized: "section.description"),
                    isOptional: true
                )
                descriptionCard

                sectionHeader(
                    title: String(localized: "section.link"),
                    isOptional: true
                )
                urlCard

                sectionHeader(
                    title: String(localized: "section.image"),
                    isOptional: true
                )
                imageCard

                sectionHeader(
                    title: String(localized: "section.audio"),
                    isOptional: true
                )
                audioCard

                if !isEditing {
                    addMoreSwitch
                }

                saveCTAButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    // MARK: - Card Views

    private var titleCard: some View {
        TextField(String(localized: "placeholder.item_title"), text: $itemTitle)
            .font(.body)
            .foregroundStyle(AppColors.cardForeground)
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.card)
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
    }

    private var descriptionCard: some View {
        TextEditor(text: $itemDescription)
            .foregroundStyle(AppColors.cardForeground)
            .font(.body)
            .frame(minHeight: 100, maxHeight: 200)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .scrollContentBackground(.hidden)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.card)
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
    }

    private var urlCard: some View {
        TextField(String(localized: "placeholder.url"), text: $itemUrl)
            .font(.body)
            .foregroundStyle(AppColors.cardForeground)
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.card)
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
    }

    private var imageCard: some View {
        InsertItemImageView(
            isEditing: isEditing,
            formImageSource: $presentedImagePicker,
            imageToDisplay: $selectedImage
        )
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.card)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }

    private var audioCard: some View {
        InsertItemAudioView(
            isRecording: $isAudioRecording,
            hasDraft: $hasAudioDraft,
            isPlaying: $isAudioPlaying,
            playbackProgress: $audioPlaybackProgress,
            onStartRecording: { onAction(.onStartAudioRecording) },
            onStopRecording: { onAction(.onStopAudioRecording) },
            onDiscardDraft: { onAction(.onDiscardAudioDraft) },
            onTogglePlayback: { onAction(.onToggleAudioPlayback) }
        )
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.card)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }

    private var saveCTAButton: some View {
        Button {
            onAction(.onSubmit)
        } label: {
            Text(
                isEditing
                    ? String(localized: "button.save_changes")
                    : String(localized: "button.create_item")
            )
            .font(.headline.weight(.semibold))
            .foregroundStyle(AppColors.accentForeground)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isButtonEnabled ? AppColors.green : AppColors.accent)
        )
        .disabled(!isButtonEnabled)
    }

    private var addMoreSwitch: some View {
        Toggle(isOn: $isAddMoreEnabled) {
            Text(String(localized: "toggle.create_more"))
                .foregroundStyle(AppColors.accentForeground)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, isOptional: Bool) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppColors.mutedForeground)

            if isOptional {
                Spacer()
                Text(String(localized: "field.optional"))
                    .font(.caption)
                    .foregroundStyle(AppColors.accentForeground)
            }
        }
        .padding(.horizontal, 4)
    }
}

extension InsertItemContentView {
    enum Action {
        case onSubmit
        case onStartAudioRecording
        case onStopAudioRecording
        case onDiscardAudioDraft
        case onToggleAudioPlayback
    }
}

#Preview("New Item") {
    InsertItemContentView(
        isEditing: false,
        onAction: { _ in },
        presentedImagePicker: .constant(nil),
        itemTitle: .constant("Item title"),
        itemDescription: .constant("Description"),
        itemUrl: .constant("google.com"),
        selectedImage: .constant(nil),
        isAddMoreEnabled: .constant(false),
        isAudioRecording: .constant(false),
        hasAudioDraft: .constant(false),
        isAudioPlaying: .constant(false),
        audioPlaybackProgress: .constant(0)
    )
}
