//
//  DeckViewModel.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 06.01.2024.
//

import Observation

enum FactionTab: String, CaseIterable {
    case northern
    case nilfgaard
    case monsters
    case scoiatael

    var description: String {
        switch self {
        case .northern:
            return "Draw a card from your deck whenever you win a round."
        case .nilfgaard:
            return "Wins any round that ends in a draw."
        case .monsters:
            return "Keeps a random Unit Card out after each round."
        case .scoiatael:
            return "Decides who takes first turn."
        }
    }

    var title: String {
        switch self {
        case .northern:
            return "Northern Realms"
        case .nilfgaard:
            return "Nilfgaardian Empire"
        case .monsters:
            return "Monsters"
        case .scoiatael:
            return "Scoiatael"
        }
    }
}

enum FilterTab: String, CaseIterable {
    case all
    case close
    case ranged
    case siege
    case hero
    case weather
    case special
}

@Observable
final class DeckViewModel {
    private(set) var activeTab: FactionTab = .northern

    private(set) var decksByFaction: [FactionTab: Deck] = [
        .northern: Deck(leader: Card.leader, faction: .northern),
        .nilfgaard: Deck(leader: Card.leader, faction: .northern),
        .monsters: Deck(leader: Card.leader, faction: .monsters),
        .scoiatael: Deck(leader: Card.leader, faction: .scoiatael),
    ]

    private(set) var collectionsByFaction: [FactionTab: [Card]] = [
        .northern: Card.all2.filter { ($0.faction == .northern || $0.faction == .neutral) && $0.type != .leader },
        .nilfgaard: Card.all2.filter { ($0.faction == .nilfgaard || $0.faction == .neutral) && $0.type != .leader },
        .monsters: Card.all2.filter { ($0.faction == .monsters || $0.faction == .neutral) && $0.type != .leader },
        .scoiatael: Card.all2.filter { ($0.faction == .scoiatael || $0.faction == .neutral) && $0.type != .leader },
    ]

    var leaderCarousel: Carousel?

    var currentLeaders: [Card] {
        Card.all2.filter { $0.type == .leader && $0.faction == currentDeck.faction }
    }

    var currentDeck: Deck {
        decksByFaction[activeTab]!
    }

    var currentCollection: [Card] {
        collectionsByFaction[activeTab]!
    }

    var isDeckPresented = false

    var prevTab: FactionTab {
        let activeIndex = FactionTab.allCases.firstIndex {
            $0 == activeTab
        }!

        return activeIndex == 0 ? FactionTab.allCases.last! : FactionTab.allCases[activeIndex - 1]
    }

    var nextTab: FactionTab {
        let activeIndex = FactionTab.allCases.firstIndex {
            $0 == activeTab
        }!

        return activeIndex == FactionTab.allCases.endIndex - 1 ? FactionTab.allCases.first! : FactionTab
            .allCases[activeIndex + 1]
    }

    func selectPrevTab() {
        activeTab = prevTab
    }

    func selectNextTab() {
        activeTab = nextTab
    }

    func addCard(_ card: Card) {
        guard let index = collectionsByFaction[activeTab]!.firstIndex(where: { $0.id == card.id }) else {
            return
        }

        collectionsByFaction[activeTab]!.remove(at: index)
        decksByFaction[activeTab]!.cards.append(card)
    }

    func showLeaderPicker() {
        let leaders = Card.all2.filter { $0.type == .leader && $0.faction == currentDeck.faction }

        leaderCarousel = Carousel(
            cards: leaders,
            count: 1,
            title: "Pick your leader.",
            cancelButton: "Hide",
            onSelect: { card in
                print("Leader is picked: ", card.name)
            }
        )
    }

    var deck: Deck = .sample1

    var count = 0

    deinit {
        print("⛔️ DeckViewModel Deinit")
    }
}
