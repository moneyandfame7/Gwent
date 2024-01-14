//
//  Array.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 21.12.2023.
//

import Foundation

extension Array {
    func randomElement(where condition: (Element) -> Bool) -> Element? {
        let filtered = filter { condition($0) }
        guard !filtered.isEmpty else { return nil }

        return filtered.randomElement()!
    }

    func reversed(_ reverse: Bool) -> [Element] {
        return reverse ? reversed() : self
    }

    func randomIndex() -> Int {
        return Int.random(in: startIndex ... endIndex)
    }

   
}
