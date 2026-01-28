//
//  InsertItemView.swift
//  lista
//
//  Created by Lucca Beurmann on 26/01/26.
//

import Foundation
import SwiftUI

struct InsertItemView: View {
    let onSubmit: (AddListaItemUiModel) -> Void
    let onDismiss: () -> Void

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var url: String = ""
    @State private var addMore: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section(
                    header: Text("Title").foregroundStyle(
                        AppColors.foreground
                    )
                ) {
                    TextField(
                        "Something cool",
                        text: $title,
                    )
                    .listRowBackground(AppColors.accent)
                }
                
                Toggle(
                    isOn: $addMore
                ) {
                    Text("Add more")
                        .foregroundStyle(AppColors.accentForeground)
                }
                .listRowBackground(AppColors.accent)
            }
            .interactiveDismissDisabled(true)
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSubmit(
                            AddListaItemUiModel(
                                title: title,
                                description: description,
                                url: url
                            ),
                        )
                        if addMore {
                            clearState()
                            return
                        }
                        onDismiss()
                    }
                    .disabled(
                        title.trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty
                    )
                }
            }
        }
    }

    private func clearState() {
        title = ""
        description = ""
        url = ""
    }
}

#Preview {
    InsertItemView { item in

    } onDismiss: {

    }

}
