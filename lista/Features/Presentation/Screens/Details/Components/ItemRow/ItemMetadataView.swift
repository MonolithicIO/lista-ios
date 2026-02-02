//
//  ItemMetadataView.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Foundation
import SwiftUI

struct ItemMetadataView: View {

    let metadata: [ItemMetadata]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(metadata, id: \.self) { metadata in
                ZStack {
                    switch metadata {
                    case .description:
                        Image(systemName: "text.page")
                    case .link:
                        Image(systemName: "link")
                    case .image:
                        Image(systemName: "photo")
                    }
                }
            }
        }
    }
}

enum ItemMetadata {
    case description
    case link
    case image
}
