//
//  DateProvider.swift
//  lista
//
//  Created by Lucca Beurmann on 20/01/26.
//

import Foundation

protocol DateProviderProtocol {
    func currentDate() throws -> Date
}

final class DateProvider: DateProviderProtocol {
    func currentDate() throws -> Date {
        return Date.now
    }
}
