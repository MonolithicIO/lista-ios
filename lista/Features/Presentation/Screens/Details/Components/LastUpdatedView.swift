//
//  LastUpdatedView.swift
//  lista
//
//  Created by Lucca Beurmann on 27/01/26.
//

import Foundation
import SwiftUI

struct LastUpdatedView: View {
    @Environment(\.locale) var locale
    let date: Date

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock")
                .font(.caption)
            Text(
                .detailsLastUpdated(
                    date.formatted(
                        .relative(presentation: .named).locale(locale)
                    )
                )
            )
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}
