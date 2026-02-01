//
//  ImagePickerView.swift
//  lista
//
//  Created by Lucca Beurmann on 01/02/26.
//

import Foundation
import SwiftUI
import UIKit

struct ImagePickerView: UIViewControllerRepresentable {

    let sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate,
        UIImagePickerControllerDelegate
    {
        private let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info:
                [UIImagePickerController.InfoKey: Any]
        ) {
            if let image =
                info[.originalImage] as? UIImage
            {
                parent.selectedImage = image
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            picker.dismiss(animated: true)
        }
    }

}
