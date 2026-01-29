//
//  FetchListFilter.swift
//  lista
//
//  Created by Lucca Beurmann on 29/01/26.
//

import Foundation

struct FetchListFilter {
    let query: String
    let state: ListState
}

enum ListState {
    case active
    case archived
    case completed
}
