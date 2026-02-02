//
//  ItemFormView.swift
//  lista
//

import Foundation
import PhotosUI
import SafariServices
import SwiftUI
import UIKit

enum ItemFormImageSource {
    case gallery
    case camera
}

struct ItemFormView: View {
    let mode: ItemFormMode
    let isParentListCompleted: Bool
    let onCreate: ((AddListaItemUiModel) -> Void)?
    let onUpdate: ((UpdateListItemDTO) -> Void)?
    let onDismiss: () -> Void

    @StateObject private var viewModel: ItemFormViewModel = ItemFormViewModel()
    @State private var imagePickerSource: ItemFormImageSource? = nil
    @State private var showSafari: Bool = false

    var body: some View {
        NavigationStack {
            List {

                if !viewModel.isWriteMode, let updatedAt = viewModel.updatedAt {
                    LastUpdatedView(date: updatedAt)
                        .listRowBackground(Color.clear)
                        .listRowInsets(
                            .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                        )
                        .listRowSeparator(.hidden)
                }

                ItemStatusBadge(
                    isItemCompleted: viewModel.isCompleted,
                )
                .listRowBackground(Color.clear)
                .listRowInsets(
                    .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                )

                Section(
                    header: Text("Title").foregroundStyle(AppColors.foreground)
                ) {
                    if viewModel.isWriteMode {
                        TextField("Item title", text: $viewModel.title)
                            .listRowBackground(AppColors.accent)
                    } else {
                        Text(viewModel.title)
                            .foregroundStyle(AppColors.foreground)
                            .listRowBackground(AppColors.accent)
                    }
                }

                // Status Toggle - Only shown in write mode when editing existing items
                if viewModel.isWriteMode && !viewModel.isCreateMode {
                    Section(
                        header: Text("Status").foregroundStyle(
                            AppColors.foreground
                        )
                    ) {
                        Toggle(isOn: $viewModel.isCompleted) {
                            HStack {
                                Image(
                                    systemName: viewModel.isCompleted
                                        ? "checkmark.circle.fill" : "circle"
                                )
                                .foregroundStyle(
                                    viewModel.isCompleted
                                        ? AppColors.green
                                        : AppColors.mutedForeground
                                )
                                Text(
                                    viewModel.isCompleted
                                        ? "Completed" : "Not completed"
                                )
                                .foregroundStyle(AppColors.foreground)
                            }
                        }
                    }
                    .listRowBackground(AppColors.accent)
                }

                // Description Section - Only shown if has content or in write mode
                if viewModel.isWriteMode || !viewModel.description.isEmpty {
                    Section(
                        header: HStack {
                            Text("Description").foregroundStyle(
                                AppColors.foreground
                            )
                            if viewModel.isWriteMode {
                                Spacer()
                                Text("Optional").foregroundStyle(
                                    AppColors.mutedForeground
                                )
                                .font(.caption)
                            }
                        }
                    ) {
                        if viewModel.isWriteMode {
                            TextEditor(text: $viewModel.description)
                                .frame(minHeight: 80)
                                .listRowBackground(AppColors.accent)
                        } else {
                            Text(viewModel.description)
                                .foregroundStyle(AppColors.foreground)
                                .listRowBackground(AppColors.accent)
                        }
                    }
                }

                // URL Section - Only shown if has content or in write mode
                if viewModel.isWriteMode || !viewModel.url.isEmpty {
                    Section(
                        header: HStack {
                            Text("URL").foregroundStyle(AppColors.foreground)
                            if viewModel.isWriteMode {
                                Spacer()
                                Text("Optional").foregroundStyle(
                                    AppColors.mutedForeground
                                )
                                .font(.caption)
                            }
                        }
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            if viewModel.isWriteMode {
                                TextField(
                                    "https://example.com",
                                    text: $viewModel.url
                                )
                                .textContentType(.URL)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                            } else {
                                Text(viewModel.url)
                                    .foregroundStyle(AppColors.foreground)
                            }

                            // Open in Safari button (visible in both modes if URL is valid)
                            if !viewModel.url.isEmpty,
                                let url = URL(string: viewModel.url),
                                UIApplication.shared.canOpenURL(url)
                            {
                                Button {
                                    showSafari = true
                                } label: {
                                    HStack {
                                        Image(systemName: "safari")
                                        Text("Open in Safari")
                                    }
                                    .font(.footnote)
                                    .foregroundStyle(AppColors.blue)
                                }
                            }
                        }
                        .listRowBackground(AppColors.accent)
                    }
                }

                // Image Section - Only shown if has image or in write mode
                if viewModel.isWriteMode || viewModel.image != nil
                    || (viewModel.originalItem?.image != nil
                        && !viewModel.shouldRemoveImage)
                {
                    ItemFormImageSection(
                        viewModel: viewModel,
                        onImageSourceSelected: { source in
                            imagePickerSource = source
                        }
                    )
                }

                // Create More Toggle - Only shown when creating new items
                if viewModel.isCreateMode {
                    Section {
                        Toggle(isOn: $viewModel.createMore) {
                            HStack {
                                Image(
                                    systemName: viewModel.createMore
                                        ? "checkmark.circle.fill" : "circle"
                                )
                                .foregroundStyle(
                                    viewModel.createMore
                                        ? AppColors.green
                                        : AppColors.mutedForeground
                                )
                                Text("Create another")
                                    .foregroundStyle(AppColors.foreground)
                            }
                        }
                    }
                    .listRowBackground(AppColors.accent)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle(viewModel.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isWriteMode {
                        // Save button in write mode
                        Button("Save") {
                            saveAction()
                        }
                        .disabled(
                            !viewModel.isSubmitEnabled || !viewModel.hasChanges
                        )
                    } else {
                        // Edit button in read mode
                        Button("Edit") {
                            withAnimation {
                                viewModel.toggleEditMode()
                            }
                        }
                    }
                }
            }
            .photosPicker(
                isPresented: Binding(
                    get: { imagePickerSource == .gallery },
                    set: { isPresented in
                        if !isPresented {
                            imagePickerSource = nil
                        }
                    }
                ),
                selection: $viewModel.galleryPickerSelection,
                matching: .images
            )
            .onChange(of: viewModel.galleryPickerSelection) { _, newValue in
                viewModel.handleGallerySelection(newValue)
            }
            .fullScreenCover(
                isPresented: Binding(
                    get: { imagePickerSource == .camera },
                    set: { isPresented in
                        if !isPresented {
                            imagePickerSource = nil
                        }
                    }
                )
            ) {
                CameraPickerView(
                    onImagePicked: { uiImage in
                        viewModel.image = uiImage
                        viewModel.shouldRemoveImage = false
                        imagePickerSource = nil
                    }
                )
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showSafari) {
                if let url = URL(string: viewModel.url),
                    UIApplication.shared.canOpenURL(url)
                {
                    SafariView(url: url)
                }
            }
            .onAppear {
                viewModel.configure(mode: mode)
            }
        }
    }

    private func saveAction() {
        switch mode {
        case .read, .write(.edit):
            // Update existing item
            if let dto = viewModel.mergeStateForUpdate() {
                onUpdate?(dto)
            }
            onDismiss()
        case .write(.create):
            // Create new item
            if let newItem = viewModel.mergeStateForCreate() {
                onCreate?(newItem)
                if viewModel.createMore {
                    // Clear fields and stay open for next item
                    viewModel.prepareForNextItem()
                } else {
                    // Dismiss the view
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Image Section
private struct ItemFormImageSection: View {
    @ObservedObject var viewModel: ItemFormViewModel
    let onImageSourceSelected: (ItemFormImageSource) -> Void

    @State private var isConfirmationDialogPresented: Bool = false

    var body: some View {
        Section(
            header: HStack {
                Text("Image").foregroundStyle(AppColors.foreground)
                if viewModel.isWriteMode {
                    Spacer()
                    Text("Optional").foregroundStyle(AppColors.mutedForeground)
                        .font(.caption)
                }
            }
        ) {
            VStack(spacing: 12) {
                if viewModel.image == nil && !viewModel.shouldRemoveImage {
                    // No image state
                    if viewModel.isWriteMode {
                        // Show placeholder for adding image
                        Button {
                            isConfirmationDialogPresented = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "photo")
                                    .font(.title3)
                                    .foregroundStyle(AppColors.blue)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Attach image")
                                        .font(.headline)
                                        .foregroundStyle(AppColors.blue)

                                    Text("Gallery or camera")
                                        .font(.caption)
                                        .foregroundStyle(
                                            AppColors.mutedForeground
                                        )
                                }

                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        style: StrokeStyle(
                                            lineWidth: 1,
                                            dash: [5]
                                        )
                                    )
                                    .foregroundStyle(AppColors.mutedForeground)
                            )
                        }
                        .confirmationDialog(
                            "",
                            isPresented: $isConfirmationDialogPresented,
                            titleVisibility: .hidden
                        ) {
                            Button("Select from gallery") {
                                onImageSourceSelected(.gallery)
                            }
                            if UIImagePickerController.isSourceTypeAvailable(
                                .camera
                            ) {
                                Button("Take photo") {
                                    onImageSourceSelected(.camera)
                                }
                            }
                        }
                    } else {
                        // Read mode - no image
                        Text("No image attached")
                            .foregroundStyle(AppColors.mutedForeground)
                            .italic()
                            .padding()
                    }
                } else {
                    // Has image state
                    ZStack(alignment: .topTrailing) {
                        if let image = viewModel.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .clipped()
                        } else {
                            // Placeholder when image was removed
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.accent)
                                .frame(height: 120)
                                .overlay(
                                    VStack {
                                        Image(systemName: "photo.slash")
                                            .font(.largeTitle)
                                            .foregroundStyle(
                                                AppColors.mutedForeground
                                            )
                                        Text("Image removed")
                                            .font(.caption)
                                            .foregroundStyle(
                                                AppColors.mutedForeground
                                            )
                                    }
                                )
                        }

                        // Action buttons (only in write mode)
                        if viewModel.isWriteMode {
                            HStack(spacing: 8) {
                                if viewModel.image != nil
                                    || viewModel.shouldRemoveImage
                                {
                                    Button {
                                        withAnimation {
                                            viewModel.removeImage()
                                        }
                                    } label: {
                                        Image(systemName: "trash.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(.red)
                                            .background(.white)
                                            .clipShape(Circle())
                                    }
                                }

                                if viewModel.shouldRemoveImage {
                                    Button {
                                        withAnimation {
                                            viewModel.cancelImageRemoval()
                                        }
                                    } label: {
                                        Image(
                                            systemName:
                                                "arrow.uturn.backward.circle.fill"
                                        )
                                        .font(.title3)
                                        .foregroundStyle(AppColors.blue)
                                        .background(.white)
                                        .clipShape(Circle())
                                    }
                                }

                                Button {
                                    isConfirmationDialogPresented = true
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(AppColors.blue)
                                        .background(.white)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(8)
                            .confirmationDialog(
                                "",
                                isPresented: $isConfirmationDialogPresented,
                                titleVisibility: .hidden
                            ) {
                                Button("Select from gallery") {
                                    onImageSourceSelected(.gallery)
                                }
                                if UIImagePickerController.isSourceTypeAvailable(
                                    .camera
                                ) {
                                    Button("Take photo") {
                                        onImageSourceSelected(.camera)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            .listRowBackground(AppColors.accent)
        }
    }
}

// MARK: - Safari View
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: Context
    ) {}
}

#Preview("Create Mode") {
    ItemFormView(
        mode: .write(.create(listId: "123")),
        isParentListCompleted: false,
        onCreate: { _ in },
        onUpdate: nil,
        onDismiss: {}
    )
}

#Preview("Read Mode - Active List") {
    ItemFormView(
        mode: .read(
            ListaItemUiModel(
                listId: "123",
                id: UUID().uuidString,
                title: "Sample Item",
                description: "A sample description",
                url: "https://example.com",
                isCompleted: false,
                image: nil,
                updatedAt: Date()
            )
        ),
        isParentListCompleted: false,
        onCreate: nil,
        onUpdate: { _ in },
        onDismiss: {}
    )
}

#Preview("Read Mode - Completed List") {
    ItemFormView(
        mode: .read(
            ListaItemUiModel(
                listId: "123",
                id: UUID().uuidString,
                title: "Sample Item",
                description: "A sample description",
                url: "https://example.com",
                isCompleted: false,
                image: nil,
                updatedAt: nil
            )
        ),
        isParentListCompleted: true,
        onCreate: nil,
        onUpdate: { _ in },
        onDismiss: {}
    )
}

#Preview("Edit Mode") {
    ItemFormView(
        mode: .write(
            .edit(
                ListaItemUiModel(
                    listId: "123",
                    id: UUID().uuidString,
                    title: "Sample Item",
                    description: "A sample description",
                    url: "https://example.com",
                    isCompleted: false,
                    image: nil,
                    updatedAt: nil
                )
            )
        ),
        isParentListCompleted: false,
        onCreate: nil,
        onUpdate: { _ in },
        onDismiss: {}
    )
}
