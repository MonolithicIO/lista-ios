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

    var screenTitleKey: LocalizedStringResource {
        if itemId != nil {
            "navigation.edit_item"
        } else {
            "navigation.create_item"
        }
    }

    var body: some View {
        InsertItemContentView(
            isEditing: self.viewModel.isEditing,
            isUrlInvalid: self.viewModel.isUrlInvalid,
            onAction: { action in
                switch action {

                case .onSubmit:
                    self.viewModel.insertItem(listId: self.listId)
                }
            },
            presentedImagePicker: self.$presentedImagePicker,
            itemTitle: self.$viewModel.title,
            itemDescription: self.$viewModel.description,
            itemUrl: self.$viewModel.url,
            selectedImage: self.$viewModel.selectedImage,
            isAddMoreEnabled: self.$viewModel.isAddMoreEnabled
        )
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.background)
        .navigationTitle(screenTitleKey)
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
    let isUrlInvalid: Bool
    let onAction: (Action) -> Void

    @Binding var presentedImagePicker: InsertItemView.PresentedImagePicker?
    @Binding var itemTitle: String
    @Binding var itemDescription: String
    @Binding var itemUrl: String
    @Binding var selectedImage: UIImage?
    @Binding var isAddMoreEnabled: Bool

    var isButtonEnabled: Bool {
        return !itemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty && !isUrlInvalid
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader(
                    title: LocalizedStringKey("section.title"),
                    isOptional: false
                )
                titleCard

                sectionHeader(
                    title: LocalizedStringKey("section.description"),
                    isOptional: true
                )
                descriptionCard

                sectionHeader(
                    title: LocalizedStringKey("section.link"),
                    isOptional: true
                )
                urlCard

                sectionHeader(
                    title: LocalizedStringKey("section.image"),
                    isOptional: true
                )
                imageCard

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
        TextField(
            "placeholder.item_title",
            text: $itemTitle
        )
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
        VStack(alignment: .leading, spacing: 6) {
            TextField("placeholder.url", text: $itemUrl)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .font(.body)
                .foregroundStyle(AppColors.cardForeground)
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColors.card)
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: 16,
                                style: .continuous
                            )
                            .stroke(
                                isUrlInvalid
                                    ? AppColors.destructive
                                    : Color.clear,
                                lineWidth: 1.5
                            )
                        )
                        .shadow(
                            color: Color.black.opacity(0.08),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                )

            if isUrlInvalid {
                Text("error.invalid_url")
                    .font(.caption)
                    .foregroundStyle(AppColors.destructive)
                    .padding(.horizontal, 4)
            }
        }
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

    private var saveCTAButton: some View {
        Button {
            onAction(.onSubmit)
        } label: {
            Text(
                isEditing
                    ? "button.save_changes"
                    : "button.create_item"
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
            Text("toggle.create_more")
                .foregroundStyle(AppColors.accentForeground)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(title: LocalizedStringKey, isOptional: Bool)
        -> some View
    {
        HStack {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppColors.mutedForeground)

            if isOptional {
                Spacer()
                Text("field.optional")
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
    }
}

#Preview("New Item") {
    InsertItemContentView(
        isEditing: false,
        isUrlInvalid: false,
        onAction: { _ in },
        presentedImagePicker: .constant(nil),
        itemTitle: .constant("Item title"),
        itemDescription: .constant("Description"),
        itemUrl: .constant("google.com"),
        selectedImage: .constant(nil),
        isAddMoreEnabled: .constant(false)
    )
}
