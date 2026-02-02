//
//  ItemStatusSwitchView.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Foundation
import SwiftUI

struct ItemStatusSwitchView: View {
    @Binding var isCompleted: Bool
    
    var body: some View {
        Section(
            header: Text("Status").foregroundStyle(
                AppColors.foreground
            )
        ) {
            Toggle(isOn: $isCompleted) {
                HStack {
                    Image(
                        systemName: isCompleted
                            ? "checkmark.circle.fill" : "circle"
                    )
                    .foregroundStyle(
                        isCompleted
                            ? AppColors.green
                            : AppColors.mutedForeground
                    )
                    Text(
                        isCompleted
                            ? "Completed" : "Not completed"
                    )
                    .foregroundStyle(AppColors.foreground)
                    .listRowBackground(AppColors.accent)
                }
            }
        }
    }
}
