//
//  RadioButton.swift
//  lista
//
//  Created by Lucca Beurmann on 25/01/26.
//

import Foundation
import SwiftUI

struct RadioButton: View {
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(
                        isCompleted
                            ? AppColors.foreground : AppColors.mutedForeground,
                        lineWidth: 2
                    )
                    .frame(width: 22, height: 22)

                if isCompleted {
                    Circle()
                        .fill(AppColors.foreground)
                        .frame(width: 12, height: 12)
                }
            }
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
    }
}

#Preview {
    RadioButton(
        isCompleted: true,
        onToggle: {}
    )
    
    RadioButton(
        isCompleted: false,
        onToggle: {}
    )
}
