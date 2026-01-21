//
//  ListCard.swift
//  lista
//
//  Created by Lucca Beurmann on 20/01/26.
//

import Foundation
import SwiftUI

struct ListCard: View {
    let item: ListaUiModel
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 8) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(AppColors.cardForeground)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColors.cardForeground)
                    .font(.title3)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)  // <- chave!
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            .contentShape(Rectangle())
        }.buttonStyle(.plain)
    }
}
