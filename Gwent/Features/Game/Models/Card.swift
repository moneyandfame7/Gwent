//
//  Card.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 21.12.2023.
//

import Foundation

struct Card: Identifiable, Hashable {
    var id: Int
    let name: String
    let image: String
    let price: Int?
    var power: Int?
    var copies: Int?
    let faction: Card.Faction
    let type: Card.CardType
    var ability: Card.Ability?
    var leaderAbility: Card.LeaderAbility?
    var combatRow: Card.Row?
    var weather: Card.Weather?

    var editedPower: Int?
    var holderIsBot: Bool?
    var shouldAnimate = false

    var animateAs: Card.Animation?

    // Це карта, якої не було у гравця, вона була створена для використання ability лідера.
    var isCreatedByLeader: Bool = false

    var availablePower: Int? {
        return editedPower ?? power
    }

    var availableRow: Card.Row? {
        combatRow == .agile ? .close : combatRow
    }
    
    var isHorn: Bool {
        ability == .commanderHorn && type == .special
    }
    
    

    // animation/animateAs: "Scorch" || "Medic" ??? + подумати про tightBond ( можна просто юзати shouldAnimate для тригера анімації )
}

extension Card: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, image, price, power, copies, type, ability
        case leaderAbility = "leader_ability"
        case combatRow = "combat_row"
        case faction, weather
    }
}

extension Card {
    static func random(faction: Card.Faction, excludeIds: [Int]) -> Self? {
        return Card.all2.randomElement { card in
            card.faction == faction
                && card.type != .leader
                && !excludeIds.contains { $0 == card.id }
        }
    }

    static func random(faction: Card.Faction, isLeader: Bool) -> Self? {
        if isLeader {
            return Card.all2.randomElement {
                $0.faction == faction && $0.type == .leader
            }
        }
        return Card.all2.randomElement {
            $0.faction == faction && $0.type != .leader
        }
    }

    static let inHand: [Self] = Array(Card.all2[0 ... 10])

    static let all2: [Self] = DataManager.shared.load("cards.json")

    static let sample: Self = Card.all2[0]

    static let leader: Self = Card.all2[59]

    static let horn: Self = Card.all2[28]

    static func weathers() -> [Self] {
        return Card.all2.filter { $0.weather != nil }
    }

    mutating func changePower(_ value: Int) {
        editedPower = value
    }
}

extension Card {
    enum Ability: String, CaseIterable, Codable {
        case agile
//        case hero
        case medic
        case moraleBoost = "morale_boost"
        case commanderHorn = "commander_horn"
        case scorch
        case decoy
        case muster
        case spy
        case tightBond = "tight_bond"

//        weathers
        case weatherClear = "weather_clear"
        case weatherFrost = "weather_frost"
        case weatherFog = "weather_fog"
        case weatherRain = "weather_rain"
    }

    enum LeaderAbility: String, CaseIterable, Codable {
        // MARK: - Nilfgaard

        case look3Cards = "look_3_cards"
        case cancelLeaderAbility = "cancel_leader_ability"
        case pickTorrentialRain = "pick_torrential_rain"
        case drawFromDiscardPile = "draw_from_discard_pile"

        // MARK: - monsters

        case restoreFromDiscardPile = "restore_from_discard_pile"
        case doubleCloseCombatPower = "double_close_combat_power"
        case discardAndDrawCards = "discard_and_draw_cards"
        case pickWeatherAndPlay = "pick_weather_and_play"

        // MARK: - Northern Realms

        case pickFogAndPlay = "pick_fog_and_play"
        case clearWeather = "clear_weather"
        case doubleSiegePower = "double_siege_power"
        case destroyStrongestSiege = "destroy_strongest_siege"

        // MARK: - Scoitael

        case drawExtraCard = "draw_extra_card"
        case pickFrostAndPlay = "pick_frost_and_play"
        case destroyStrongestClose = "destroy_strongest_close"
        case doubleRangedPower = "double_ranged_power"
    }

    enum Row: String, CaseIterable, Codable {
        case close, agile, ranged, siege
    }

    enum Faction: String, CaseIterable, Codable {
        case northern, nilfgaard, monsters, scoiatael, neutral

        var formatted: String {
            switch self {
            case .nilfgaard:
                "Nilfgaard"
            case .northern:
                "Northern Realms"
            case .monsters:
                "Monsters"
            case .scoiatael:
                "Scoiatael"
            case .neutral:
                "Neutral"
            }
        }

//        var shieldImage: String {
//            switch
//        }
    }

    enum Weather: String, CaseIterable, Codable {
        case bitingFrost = "biting_frost"
        case impenetrableFog = "impenetrable_fog"
        case torrentialRain = "torrential_rain"
        case clearWeather = "clear_weather"
    }

    enum CardType: String, CaseIterable, Codable {
        case unit, leader, hero, weather, special
    }

    enum Animation: String {
        case scorch, medic
    }
}

extension Card {
    /// enum CardSoundAsset
    /// weather(Card.Weather)
    /// unit(Card.Row)
    /// hero
    /// ability(Card.Ability)
    static func getSoundAsset(weather: Card.Weather) -> SoundManager.SoundName {
        switch weather {
        case .bitingFrost:
            return .frost
        case .impenetrableFog:
            return .fog
        case .torrentialRain:
            return .rain
        case .clearWeather:
            return .clearWeather
        }
    }
}
