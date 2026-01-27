//
//  DetailsContextMenuView.swift
//  lista
//
//  Created by Lucca Beurmann on 26/01/26.
//

import Foundation
import SwiftUI

struct DetailsContextMenuView: View {
    
    let onArchive: () -> Void
    let onUndoArchive: () -> Void
    let onDelete: () -> Void
    let onComplete: () -> Void
    let onUndoCompletion: () -> Void
    let isCompleted: Bool
    let isArquived: Bool

    var body: some View {
        Menu {
            if isCompleted {
                Button(
                    "Undo completion",
                    systemImage: "arrow.uturn.backward.circle"
                ) {
                    onUndoCompletion()
                }
                .disabled(isArquived)
            } else {
                Button(
                    "Mark as completed",
                    systemImage: "checkmark.circle"
                ) {
                    onComplete()
                }
                .disabled(isArquived)
            }
            
            if isArquived {
                Button(
                    "Undo archive",
                    systemImage: "arrow.uturn.backward.circle"
                ) {
                    onUndoArchive()
                }
                
            } else {
                Button(
                    "Archive",
                    systemImage: "archivebox"
                ) {
                    onArchive()
                }
            }

            Divider()

            Button(
                "Delete",
                systemImage: "trash",
                role: .destructive
            ) {
                onDelete()
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .symbolRenderingMode(.hierarchical)
        }
    }

}
