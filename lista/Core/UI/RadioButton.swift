//
//  RadioButton.swift
//  lista
//
//  Created by Lucca Beurmann on 25/01/26.
//

import Foundation
import SwiftUI

struct RadioButton: View {
    let isChecked: Bool
    let onToggle: () -> Void
    let isEnabled: Bool

    var body: some View {
        Button {
            guard isEnabled else { return }

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
                        strokeColor,
                        lineWidth: 2
                    )
                    .frame(width: 22, height: 22)

                if isChecked {
                    Circle()
                        .fill(fillColor)
                        .frame(width: 12, height: 12)
                        .transition(
                            .scale(scale: 0.6)
                                .combined(with: .opacity)
                        )
                }
            }
            .opacity(isEnabled ? 1.0 : 0.4)
            .animation(
                .spring(
                    response: 0.22,
                    dampingFraction: 0.85
                ),
                value: isChecked
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityElement()
    }

    // MARK: - Computed styles

    private var strokeColor: Color {
        if !isEnabled {
            return AppColors.mutedForeground
        }
        return isChecked
            ? AppColors.foreground
            : AppColors.mutedForeground
    }

    private var fillColor: Color {
        if !isEnabled {
            return AppColors.mutedForeground
        }
        return AppColors.foreground
    }
}


#Preview {
    RadioButton(
        isChecked: true,
        onToggle: {},
        isEnabled: true
    )

    RadioButton(
        isChecked: false,
        onToggle: {},
        isEnabled: true
    )
    
    RadioButton(
        isChecked: false,
        onToggle: {},
        isEnabled: false
    )
}
