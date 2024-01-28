//
//  DeckViewModel.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 06.01.2024.
//

import Observation

@Observable
final class DeckViewModel {
    private(set) var activeTab: FactionTab = .northern

    var toast: String?

    private(set) var decksByFaction: [FactionTab: Deck] = [
        .northern: Deck(leader: Card.leader, faction: .northern),
        .nilfgaard: Deck(leader: Card.leader, faction: .nilfgaard),
        .monsters: Deck(leader: Card.leader, faction: .monsters),
        .scoiatael: Deck(leader: Card.leader, faction: .scoiatael),
    ]

    private(set) var collectionsByFaction: [FactionTab: [Card]] = {
        var collections: [FactionTab: [Card]] = [:]

        FactionTab.allCases.forEach { tab in
            collections[tab] = Card.all2
                .filter { ($0.faction.rawValue == tab.rawValue || $0.faction == .neutral) && $0.type != .leader }
        }

        return collections
    }()

    var leaderCarousel: Carousel?

    var currentLeaders: [Card] {
        Card.all2.filter { $0.type == .leader && $0.faction == currentDeck.faction }
    }

    var currentDeck: Deck {
        decksByFaction[activeTab]!
    }

    var deckStats: DeckStats {
        let total = currentDeck.cards.count

        let units = currentDeck.cards.filter { $0.type == .unit || $0.type == .hero }.count

        let specials = currentDeck.cards.filter { $0.type == .special || $0.type == .weather }.count

        let power = currentDeck.cards.reduce(0) { $0 + ($1.power ?? 0) }

        let heroes = currentDeck.cards.filter { $0.type == .hero }.count

        return DeckStats(total: total, units: units, specials: specials, power: power, heroes: heroes)
    }

    var currentCollection: [Card] {
        collectionsByFaction[activeTab]!
    }

    func changeLeader(_ card: Card) {
        decksByFaction[activeTab]!.leader = card
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

    func startGame(completion: @escaping () -> Void) {
        let isDeckValid = validateDeck()

        guard isDeckValid else {
            // show toast
            toast = "Units Cards Error"
            return
        }

        completion()
        // navigate to ...
    }

    private func validateDeck() -> Bool {
        return deckStats.units >= 22
    }

    func addCard(_ card: Card) {
        guard let index = collectionsByFaction[activeTab]!.firstIndex(where: { $0.id == card.id }) else {
            return
        }
        if (card.type == .weather || card.type == .special) && deckStats.specials >= 10 {
            toast = "Special Cards Limit"

            return
        }

        collectionsByFaction[activeTab]!.remove(at: index)
        decksByFaction[activeTab]!.cards.append(card)
    }

    func removeCard(_ card: Card) {
        guard let index = decksByFaction[activeTab]!.cards.firstIndex(where: { $0.id == card.id }) else {
            return
        }

        decksByFaction[activeTab]!.cards.remove(at: index)
        collectionsByFaction[activeTab]!.append(card)
    }

    func showLeaderPicker() {
        let leaders = Card.all2.filter { $0.type == .leader && $0.faction == currentDeck.faction }

        leaderCarousel = Carousel(
            cards: leaders,
            count: 1,
            title: "Pick your leader.",
            initID: currentDeck.leader.id,
            cancelButton: "Hide",
            onSelect: { [unowned self] card in
                changeLeader(card)
            }
        )
    }

    deinit {
        print("⛔️ DeckViewModel Deinit")
    }
}

extension DeckViewModel {
    static let preview = DeckViewModel()
}
