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
            withAnimation(
                .spring(
                    response: 0.22,
                    dampingFraction: 0.85,
                    blendDuration: 0
                )
            ) {
                onToggle()
            }
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(
                        isCompleted
                            ? AppColors.foreground
                            : AppColors.mutedForeground,
                        lineWidth: 2
                    )
                    .frame(width: 22, height: 22)

                if isCompleted {
                    Circle()
                        .fill(AppColors.foreground)
                        .frame(width: 12, height: 12)
                        .transition(
                            .scale(scale: 0.6)
                                .combined(with: .opacity)
                        )
                }
            }
            .animation(
                .spring(
                    response: 0.22,
                    dampingFraction: 0.85
                ),
                value: isCompleted
            )
        }
        .buttonStyle(.plain)
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
