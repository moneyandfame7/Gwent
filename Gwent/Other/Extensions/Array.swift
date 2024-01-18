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
        if filtered.isEmpty { return nil }

        return filtered.randomElement()!
    }

    func reversed(_ reverse: Bool) -> [Element] {
        return reverse ? reversed() : self
    }

    func randomIndex() -> Int {
        return Int.random(in: startIndex ..< endIndex)
    }
}

extension Array where Element: Identifiable {
    subscript(id: Element.ID) -> Element? {
        first { $0.id == id }
    }

    func randomElements(where predicate: ((Element) -> Bool)? = nil, count: Int = 1) -> [Element] {
        /// self.isEmpty
        if isEmpty { return [] }

        let elements = predicate != nil ? filter(predicate!) : self

        if elements.isEmpty {
            return []
        }

        var randomized: [Element] = []

        for _ in 0 ..< count {
            guard let randomEl = randomElement(where: { random in
                !randomized.contains(where: { $0.id == random.id })
            }) else {
                break
            }

            randomized.append(randomEl)
        }

        return randomized
    }
}
