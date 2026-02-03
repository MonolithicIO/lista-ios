//
//  ItemImageSectionView.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Foundation
import SwiftUI

struct InsertItemImageView: View {
    let isEditing: Bool

    @State private var isConfirmationDialogPresented: Bool = false
    @Binding var formImageSource: ItemFormImageSource?
    @Binding var imageToDisplay: UIImage?

    var body: some View {
        WriteModeView(
            isConfirmationDialogPresented: $isConfirmationDialogPresented,
            formImageSource: $formImageSource,
            image: $imageToDisplay
        )
    }
}

// MARK: - Write mode Image
private struct WriteModeView: View {

    @Binding var isConfirmationDialogPresented: Bool
    @Binding var formImageSource: ItemFormImageSource?
    @Binding var image: UIImage?

    var body: some View {

        Section(
            header: HStack {
                Text("Image").foregroundStyle(AppColors.foreground)
                Spacer()
                Text("Optional").foregroundStyle(AppColors.mutedForeground)
                    .font(.caption)
            }
        ) {
            VStack(spacing: 12) {
                if let itemImage = image {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: itemImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .clipped()

                        HStack(spacing: 8) {
                            Button {
                                withAnimation {
                                    image = nil
                                }
                            } label: {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.red)
                                    .background(.white)
                                    .clipShape(Circle())
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
                    }
                } else {
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
                        isPresented: $isConfirmationDialogPresented
                    ) {
                        Button("Select from gallery") {
                            formImageSource = .gallery
                        }

                        if UIImagePickerController.isSourceTypeAvailable(
                            .camera
                        ) {
                            Button("Take photo") {
                                formImageSource = .camera
                            }
                        }
                    }
                }
            }
        }
    }
}
