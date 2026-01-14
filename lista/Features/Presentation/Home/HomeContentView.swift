//
//  HomeContentView.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI

struct HomeContentView: View {
    var body: some View {
        VStack {
            Text("Home view")
        }.background(AppColors.background)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "gearshape.fill")
                }
            }
        
    }
}

#Preview {
    HomeContentView()
}
