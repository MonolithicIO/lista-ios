//
//  ListsView.swift
//  lista
//
//  Created by Lucca Beurmann on 17/01/26.
//

import Foundation
import SwiftUI

struct ListaItemsView: View {
    let items: [ListaItemUiModel]
    let onItemTap: (ListaItemUiModel) -> Void

    var body: some View {

        if items.isEmpty {
            EmptyListsView()
        } else {
            FilledListsView(items: items, onItemTap: onItemTap)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct EmptyListsView: View {
    var body: some View {
        Text("List empty")
    }
}

private struct FilledListsView: View {
    let items: [ListaItemUiModel]
    let onItemTap: (ListaItemUiModel) -> Void

    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(items) { list in
                ListaItemCardView(
                    item: list,
                    onTap: {
                        onItemTap(list)
                    }
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
