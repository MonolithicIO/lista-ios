//
//  AddListView.swift
//  lista
//
//  Created by Lucca Beurmann on 18/01/26.
//

import Foundation
import SwiftUI

struct AddListView: View {
    let onDismiss: () -> Void
    let onSubmit: (String) -> Void

    @State private var listTitle: String = ""
    
    var isAddButtonEnabled: Bool {
        !listTitle.isEmpty
    }

    var body: some View {
        VStack {
            TextField("Title", text: $listTitle)
                .textFieldStyle(.roundedBorder)
                .padding()
                .submitLabel(.done)

        }
        .navigationTitle("New list")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    onDismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    onSubmit(listTitle)
                }.disabled(!isAddButtonEnabled)
            }
        }
    }
}
