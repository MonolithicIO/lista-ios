//
//  InsertItemViewModel.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Foundation
import Combine
import PhotosUI
import UIKit
import SwiftUI

final class InsertItemViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var url: String = ""
    @Published var addMore: Bool = false
    @Published var galleryPickerSelection: PhotosPickerItem?
    @Published var image: UIImage?

    var isSubmitEnabled: Bool {
        return title.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    init() {}

    func mergeState() -> AddListaItemUiModel {
        return AddListaItemUiModel(
            title: self.title,
            description: self.description,
            url: self.url,
            attachedImage: self.image
        )
    }

    func clearState() {
        title = ""
        description = ""
        url = ""
        galleryPickerSelection = nil
        image = nil
    }
    
    func onClearImage() {
        image = nil
    }
    
    func handleGallerySelection(_ item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                    self.galleryPickerSelection = nil
                }
            }
        }
    }

}
