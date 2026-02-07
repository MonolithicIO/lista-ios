//
//  LastUpdatedView.swift
//  lista
//
//  Created by Lucca Beurmann on 27/01/26.
//

import Foundation
import SwiftUI

struct LastUpdatedView: View {
    let date: Date

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock")
                .font(.caption)
            Text("\(String(localized: "details.last_updated")) \(date.formatted(.relative(presentation: .named)))")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}
