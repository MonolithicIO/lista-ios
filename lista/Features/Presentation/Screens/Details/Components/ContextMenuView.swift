//
//  DetailsContextMenuView.swift
//  lista
//
//  Created by Lucca Beurmann on 26/01/26.
//

import Foundation
import SwiftUI

enum DetailsMenuAction {
    case archive
    case undoArchive
    case delete
    case complete
    case undoComplete
}

struct DetailsContextMenuView: View {
    
    let isCompleted: Bool
    let isArquived: Bool
    let onAction: (DetailsMenuAction) -> Void

    var body: some View {
        Menu {
            if isCompleted {
                Button(
                    "Undo completion",
                    systemImage: "arrow.uturn.backward.circle"
                ) {
                    onAction(.undoComplete)
                }
                .disabled(isArquived)
            } else {
                Button(
                    "Mark as completed",
                    systemImage: "checkmark.circle"
                ) {
                    onAction(.complete)
                }
                .disabled(isArquived)
            }
            
            if isArquived {
                Button(
                    "Undo archive",
                    systemImage: "arrow.uturn.backward.circle"
                ) {
                    onAction(.undoArchive)
                }
                
            } else {
                Button(
                    "Archive",
                    systemImage: "archivebox"
                ) {
                    onAction(.archive)
                }
            }

            Divider()

            Button(
                "Delete",
                systemImage: "trash",
                role: .destructive
            ) {
                onAction(.delete)
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .symbolRenderingMode(.hierarchical)
        }
    }

}
