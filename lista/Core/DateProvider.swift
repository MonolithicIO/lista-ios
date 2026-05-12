//
//  DateProvider.swift
//  lista
//
//  Created by Lucca Beurmann on 20/01/26.
//

import Foundation

protocol DateProviderProtocol {
    func currentDate() -> Date
}

final class DateProvider: DateProviderProtocol {
    func currentDate() -> Date {
        return Date.now
    }
}
