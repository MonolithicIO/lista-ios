//
//  DetailsContentView.swift
//  lista
//
//  Created by Lucca Beurmann on 14/01/26.
//

import SwiftUI

struct DetailsScreen: View {
    let listaId: String
    
    var body: some View {
        VStack {
            Text("Details: \(listaId)")
        }
    }
}
