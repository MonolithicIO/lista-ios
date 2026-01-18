//
//  AddListView.swift
//  lista
//
//  Created by Lucca Beurmann on 18/01/26.
//

import Foundation
import SwiftUI

struct AddListView: View {
    @Environment(\.dismiss) private var dismiss
    let onSubmit: (String) -> Void

    @State private var listTitle: String = ""

    var body: some View {

        VStack {

        }
        .navigationTitle("New list")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    onSubmit(listTitle)
                    dismiss()
                }
            }
        }
    }
}
