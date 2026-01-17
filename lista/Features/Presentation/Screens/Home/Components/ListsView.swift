//
//  ListsView.swift
//  lista
//
//  Created by Lucca Beurmann on 17/01/26.
//

import Foundation
import SwiftUI

struct ListsView: View {
    let items: [ListUiModel]
    
    var body: some View {
        
        if items.isEmpty {
            EmptyListsView()
        } else {
            FilledListsView(items: items)
        }
    }
}

private struct EmptyListsView: View {
    var body: some View {
        Text("List empty")
    }
}

private struct FilledListsView: View {
    let items: [ListUiModel]

    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(items) { list in
                Text(list.title)
            }
        }
    }
}
