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
                    LocalizedStringKey("menu.undo_completion"),
                    systemImage: "arrow.uturn.backward.circle"
                ) {
                    onAction(.undoComplete)
                }
                .disabled(isArquived)
            } else {
                Button(
                    LocalizedStringKey("menu.mark_completed"),
                    systemImage: "checkmark.circle"
                ) {
                    onAction(.complete)
                }
                .disabled(isArquived)
            }

            if isArquived {
                Button(
                    LocalizedStringKey("menu.undo_archive"),
                    systemImage: "arrow.uturn.backward.circle"
                ) {
                    onAction(.undoArchive)
                }
                .disabled(isCompleted)

            } else {
                Button(
                    LocalizedStringKey("menu.archive"),
                    systemImage: "archivebox"
                ) {
                    onAction(.archive)
                }
                .disabled(isCompleted)
            }

            Divider()

            Button(
                LocalizedStringKey("menu.delete"),
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
