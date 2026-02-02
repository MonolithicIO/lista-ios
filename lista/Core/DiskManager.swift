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
}
