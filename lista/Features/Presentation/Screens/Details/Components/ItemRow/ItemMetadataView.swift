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
                    Image(systemName: metadata.systemName)
                        .font(.caption)
                        .foregroundStyle(AppColors.foreground.opacity(0.5))
                }
            }
        }
    }
}

enum ItemMetadata {
    case description
    case link
    case image

    var systemName: String {
        switch self {
        case .description:
            return "text.page"
        case .link:
            return "link"
        case .image:
            return "camera"
        }
    }
}

#Preview {
    ItemMetadataView(metadata: [.description, .image, .link])
}
