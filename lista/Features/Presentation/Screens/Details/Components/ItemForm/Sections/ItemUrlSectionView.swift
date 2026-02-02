//
//  ItemUrlSectionView.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Foundation
import SwiftUI


struct ItemUrlSectionView: View {
    let isWriteMode: Bool
    @Binding var showSafari: Bool
    @Binding var url: String
    
    var body: some View {
        Section(
            header: HStack {
                Text("URL").foregroundStyle(AppColors.foreground)
                if isWriteMode {
                    Spacer()
                    Text("Optional").foregroundStyle(
                        AppColors.mutedForeground
                    )
                    .font(.caption)
                }
            }
        ) {
            VStack(alignment: .leading, spacing: 8) {
                if isWriteMode {
                    TextField(
                        "https://example.com",
                        text: $url
                    )
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                } else {
                    Text(url)
                        .foregroundStyle(AppColors.foreground)
                }

                // Open in Safari button (visible in both modes if URL is valid)
                if !url.isEmpty,
                    let url = URL(string: url),
                    UIApplication.shared.canOpenURL(url)
                {
                    Button {
                        showSafari = true
                    } label: {
                        HStack {
                            Image(systemName: "safari")
                            Text("Open in Safari")
                        }
                        .font(.footnote)
                        .foregroundStyle(AppColors.blue)
                    }
                }
            }
            .listRowBackground(AppColors.accent)
        }
    }
}
