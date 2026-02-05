//
//  AddListView.swift
//  lista
//
//  Redesigned with modern card-based layout
//

import Foundation
import SwiftUI

struct AddListView: View {
    // MARK: - Env properties
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State properties
    @State private var listTitle: String = ""
    var isAddButtonEnabled: Bool {
        !listTitle.isEmpty
    }
    
    // MARK: - Input properties
    let onSubmit: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // List Name Section
                sectionHeader(title: "List Name", isOptional: false)
                titleCard

                // Create List CTA Button
                createListCTAButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.background)
        .navigationTitle("New List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Card Views

    private var titleCard: some View {
        TextField("Enter list name", text: $listTitle)
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

    private var createListCTAButton: some View {
        Button {
            onSubmit(listTitle)
        } label: {
            Text("Create List")
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppColors.accentForeground)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.accent)
        )
        .disabled(!isAddButtonEnabled)
        .opacity(isAddButtonEnabled ? 1.0 : 0.6)
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, isOptional: Bool) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColors.mutedForeground)

            if isOptional {
                Spacer()
                Text("Optional")
                    .font(.caption)
                    .foregroundStyle(AppColors.accent)
            }
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    NavigationStack {
        AddListView(
            onSubmit: { _ in }
        )
    }
}
