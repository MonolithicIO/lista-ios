//
//  UUIDProvider.swift
//  lista
//
//  Created by Lucca Beurmann on 02/02/26.
//

import Foundation

protocol UUIDProviderProtocol {
    func provide() -> UUID
}

final class UUIDProvider: UUIDProviderProtocol {
    func provide() -> UUID {
        return UUID()
    }
}
