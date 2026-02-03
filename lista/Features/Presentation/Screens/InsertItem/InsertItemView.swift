//
//  InsertItemView.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Foundation
import SwiftUI
import PhotosUI

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
        if viewModel.isEditing {
            "Edit item"
        } else {
            "Create Item"
        }
    }

    var body: some View {
        InsertItemContentView(
            navTitle: screenTitle,
            onAction: { action in
                switch action {

                case .onSubmit:
                    self.viewModel.insertItem(listId: self.listId)
                }
            },
            itemTitle: $viewModel.title,
            itemDescription: $viewModel.description,
            itemUrl: $viewModel.url
        )
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
    let navTitle: String
    let onAction: (Action) -> Void

    @Binding var itemTitle: String
    @Binding var itemDescription: String
    @Binding var itemUrl: String

    var body: some View {
        Form {
            InsertSection(
                title: "Title",
                isOptional: false
            ) {
                TextField("Item title", text: $itemTitle)
            }

            InsertSection(
                title: "Description",
                isOptional: true
            ) {
                TextEditor(text: $itemDescription)
                    .frame(minHeight: 60, maxHeight: 100)
            }

            InsertSection(
                title: "Link",
                isOptional: true
            ) {
                TextField("Item title", text: $itemUrl)
            }

        }
        .navigationTitle(navTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    onAction(.onSubmit)
                }
            }
        }
    }
}

extension InsertItemContentView {
    enum Action {
        case onSubmit
    }
}

private struct InsertSection<Content: View>: View {
    let title: String
    let isOptional: Bool
    var content: Content

    init(title: String, isOptional: Bool, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.title = title
        self.isOptional = isOptional
    }

    var body: some View {
        Section(
            header: HStack {
                Text(title).foregroundStyle(.appForeground)
                if isOptional {
                    Spacer()
                    Text("Optional")
                        .foregroundStyle(.appAccentForeground)
                        .font(.caption)
                }
            }
        ) {
            content
        }
    }
}
