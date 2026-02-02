//
//  ItemTitleSection.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Foundation
import SwiftUI

struct ItemTitleSectionView: View {
    let isWriteMode: Bool
    @Binding var title: String

    var body: some View {
        Section(
            header: Text("Title").foregroundStyle(AppColors.foreground)
        ) {
            if isWriteMode {
                TextField("Item title", text: $title)
                    .listRowBackground(AppColors.accent)
            } else {
                Text(title)
                    .foregroundStyle(AppColors.foreground)
                    .listRowBackground(AppColors.accent)
            }
        }
    }
}
