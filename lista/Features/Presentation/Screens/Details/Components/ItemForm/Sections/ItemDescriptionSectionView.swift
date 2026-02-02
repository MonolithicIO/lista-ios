//
//  ItemDescriptionSectionView.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Foundation
import SwiftUI

struct ItemDescriptionSectionView: View {
    
    let isWriteMode: Bool
    @Binding var description: String
    
    var body: some View {
        Section(
            header: HStack {
                Text("Description").foregroundStyle(
                    AppColors.foreground
                )
                if isWriteMode {
                    Spacer()
                    Text("Optional").foregroundStyle(
                        AppColors.mutedForeground
                    )
                    .font(.caption)
                }
            }
        ) {
            if isWriteMode {
                TextEditor(text: $description)
                    .frame(minHeight: 80)
                    .listRowBackground(AppColors.accent)
            } else {
                Text(description)
                    .foregroundStyle(AppColors.foreground)
                    .listRowBackground(AppColors.accent)
            }
        }
    }
}
