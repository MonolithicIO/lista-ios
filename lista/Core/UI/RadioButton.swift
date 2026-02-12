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
                        lineWidth: 1.5
                    )
                    .frame(width: 18, height: 18)

                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(fillColor)
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
        .disabled(!isEnabled)
        .accessibilityElement()
    }

    // MARK: - Computed styles

    private var strokeColor: Color {
        if !isEnabled {
            return AppColors.mutedForeground
        }
        return isChecked
            ? AppColors.green
            : AppColors.blue.opacity(0.4)
    }

    private var fillColor: Color {
        if !isEnabled {
            return AppColors.mutedForeground
        }
        return AppColors.green
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
