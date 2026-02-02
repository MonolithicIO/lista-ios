//
//  DiskManager.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Foundation
import UIKit

protocol DiskManagerProtocol {
    func saveImage(image: UIImage, fileName: String) throws -> String
    func deleteImage(fileName: String) throws
    func loadImage(fileName: String) throws -> UIImage
}

final class DiskManager: DiskManagerProtocol {

    func saveImage(image: UIImage, fileName: String) throws -> String {
        let data = image.jpegData(compressionQuality: 0.9)!
        let directory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        let fileUrl = directory.appendingPathComponent("\(fileName).jpg")

        try data.write(to: fileUrl, options: .atomic)

        return fileUrl.path()
    }

    func deleteImage(fileName: String) throws {
        let directory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        let fileUrl = directory.appendingPathComponent("\(fileName).jpg")

        if FileManager.default.fileExists(atPath: fileUrl.path) {
            try FileManager.default.removeItem(at: fileUrl)
        }
    }

    func loadImage(fileName: String) throws -> UIImage {
        let directory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        let fileUrl = directory.appendingPathComponent("\(fileName).jpg")

        guard FileManager.default.fileExists(atPath: fileUrl.path) else {
            throw NSError(
                domain: "DiskManager",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Image file not found: \(fileName).jpg"]
            )
        }

        guard let data = try? Data(contentsOf: fileUrl),
              let image = UIImage(data: data) else {
            throw NSError(
                domain: "DiskManager",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "Failed to load image: \(fileName).jpg"]
            )
        }

        return image
    }
}
