//
//  ItemDetailsView.swift
//  lista
//
//  Redesigned with modern card-based layout
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
    let onToggle: () -> Void
    let enableEdit: Bool

    @State private var showSafari: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Status badge (subtle, centered)
                    ItemStatusBadge(isItemCompleted: item.isCompleted)
                        .padding(.top, 8)

                    // Title Card
                    sectionTitle(String(localized: "section.title"))
                    titleCard

                    // Description Card (if exists)
                    if let itemDescription = item.description {
                        sectionTitle(String(localized: "section.description"))
                        descriptionCard(description: itemDescription)
                    }

                    // URL Card (action-oriented button style)
                    if let itemUrl = item.url {
                        sectionTitle(String(localized: "section.link"))
                        urlCard(url: itemUrl)
                    }

                    // Image Card (if exists)
                    if let imagePath = item.image,
                        let image = UIImage(
                            contentsOfFile: imageURL(from: imagePath).path()
                        )
                    {
                        sectionTitle(String(localized: "section.image"))
                        imageCard(image: image)
                    }

                    // Complete CTA Button
                    completeCTAButton

                    // Last Updated (subtle, at bottom)
                    if let updatedAt = item.updatedAt {
                        lastUpdatedText(date: updatedAt)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppColors.background)
            .navigationTitle(String(localized: "navigation.item_details"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        onUpdate()
                    }) {
                        Image(systemName: "pencil")
                    }
                    .accessibilityLabel(String(localized: "accessibility.edit_item"))
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

    // MARK: - Card Views

    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppColors.cardForeground)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 20)
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

    private func descriptionCard(description: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(description)
                .font(.body)
                .foregroundStyle(AppColors.cardForeground)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    private func urlCard(url: String) -> some View {
        Button {
            if !url.isEmpty,
                let validUrl = URL(string: url),
                UIApplication.shared.canOpenURL(validUrl)
            {
                showSafari = true
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "link.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppColors.accentForeground)

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "button.open_link"))
                        .font(.headline.weight(.medium))
                        .foregroundStyle(AppColors.accentForeground)

                    Text(url)
                        .font(.caption)
                        .foregroundStyle(
                            AppColors.accentForeground.opacity(0.8)
                        )
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColors.accentForeground.opacity(0.7))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.accent)
        )
    }

    private func imageCard(image: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
        }
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

    private var completeCTAButton: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: 8) {
                Image(
                    systemName: item.isCompleted
                        ? "arrow.uturn.backward" : "checkmark"
                )
                .font(.headline.weight(.semibold))
                Text(item.isCompleted ? String(localized: "toggle.mark_active") : String(localized: "toggle.mark_complete"))
                    .font(.headline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(item.isCompleted ? AppColors.orange : AppColors.green)
        )
        .disabled(!enableEdit)
        .opacity(enableEdit ? 1.0 : 0.6)
    }

    private func lastUpdatedText(date: Date) -> some View {
        Text(
            String(format: String(localized: "details.updated_on"), date.formatted(date: .abbreviated, time: .shortened))
        )
        .font(.caption)
        .foregroundStyle(AppColors.mutedForeground)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 8)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppColors.mutedForeground)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }
}

#Preview("Active Item") {
    ItemDetailsView(
        item: ListaItemUiModel(
            listId: "123",
            id: UUID().uuidString,
            title: "Buy groceries for the weekend",
            description:
                "Milk, eggs, bread, and some fresh vegetables from the farmer's market",
            url: "https://example.com/list",
            isCompleted: false,
            image: nil,
            updatedAt: Date()
        ),
        onUpdate: {},
        onToggle: {},
        enableEdit: true
    )
}

#Preview("Completed Item") {
    ItemDetailsView(
        item: ListaItemUiModel(
            listId: "123",
            id: UUID().uuidString,
            title: "Buy groceries for the weekend",
            description:
                "Milk, eggs, bread, and some fresh vegetables from the farmer's market",
            url: "https://example.com/list",
            isCompleted: true,
            image: nil,
            updatedAt: Date()
        ),
        onUpdate: {},
        onToggle: {},
        enableEdit: true
    )
}
