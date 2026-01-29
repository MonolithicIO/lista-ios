//
//  ListCard.swift
//  lista
//
//  Created by Lucca Beurmann on 20/01/26.
//

import Foundation
import SwiftUI

struct ListaCardView: View {
    let item: ListaUiModel

    var body: some View {
        HStack {
            Text(item.title)
                .font(.body.weight(.medium))
                .foregroundStyle(AppColors.accentForeground)
                .lineLimit(1)

            Spacer()
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColors.accentForeground)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}
