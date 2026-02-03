//
//  ItemFormView.swift
//  lista
//

import Foundation
import PhotosUI
import SafariServices
import SwiftUI
import UIKit

struct ItemDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    let item: ListaItemUiModel
    let onUpdate: () -> Void
    let enableEdit: Bool

    @State private var showSafari: Bool = false

    var body: some View {
        NavigationStack {
            List {
                if let updatedAt = item.updatedAt {
                    LastUpdatedView(date: updatedAt)
                        .listRowBackground(Color.clear)
                        .listRowInsets(
                            .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                        )
                        .listRowSeparator(.hidden)
                }

                ItemStatusBadge(
                    isItemCompleted: item.isCompleted,
                )
                .listRowBackground(Color.clear)
                .listRowInsets(
                    .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                )

                Section(
                    header: Text("Title").foregroundStyle(AppColors.foreground)
                ) {
                    Text(item.title)
                        .foregroundStyle(AppColors.foreground)
                        .listRowBackground(AppColors.accent)
                }

                if let itemDescription = item.description {
                    Section(
                        header: HStack {
                            Text("Description").foregroundStyle(
                                AppColors.foreground
                            )
                        }
                    ) {
                        Text(itemDescription)
                            .foregroundStyle(AppColors.foreground)
                            .listRowBackground(AppColors.accent)
                    }
                }

                if let itemUrl = item.url {
                    Section(
                        header: HStack {
                            Text("URL").foregroundStyle(AppColors.foreground)
                        }
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(itemUrl)
                                .foregroundStyle(AppColors.foreground)

                            // Open in Safari button (visible in both modes if URL is valid)
                            if !itemUrl.isEmpty,
                                let url = URL(string: itemUrl),
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

                if let imagePath = item.image,
                   let image = UIImage(contentsOfFile: imageURL(from: imagePath).path())
                {
                    Section(
                        header: HStack {
                            Text("Image").foregroundStyle(
                                AppColors.foreground
                            )
                        }
                    ) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .clipped()
                    }
                    .listRowBackground(AppColors.accent)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle("Item Details")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        onUpdate()
                    }) {
                        Image(systemName: "pencil")
                    }
                    .accessibilityLabel("Edit Item")
                    .disabled(!enableEdit)
                }
            }
            .sheet(isPresented: $showSafari) {
                if let itemUrl = item.url, let url = URL(string: itemUrl) {
                    SafariView(url: url)
                }
            }
        }
    }
}

#Preview() {
    ItemDetailsView(
        item: ListaItemUiModel(
            listId: "123",
            id: UUID().uuidString,
            title: "Sample Item",
            description: "A sample description",
            url: "https://example.com",
            isCompleted: false,
            image: nil,
            updatedAt: Date()
        ),
        onUpdate: {},
        enableEdit: false
    )
}
