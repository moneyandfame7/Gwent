//
//  CombatRow.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 21.12.2023.
//

import Foundation

enum CardAnimation: String {
    case scorch, medic
}

struct Card: Identifiable, Hashable {
    let id: Int
    let name: String
    let image: String
    let price: Int?
    var power: Int?
    var copies: Int?
    let faction: Card.Faction
    let type: Card.CardType
    var ability: Card.Ability?
    var leaderAbility: Card.LeaderAbility?
    var combatRow: Card.CombatRow?
    var weather: Card.Weather?

    var editedPower: Int?
    var holderIsBot: Bool?
    var shouldAnimate = false

    var animateAs: CardAnimation?
    
   
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

    static func weathers() -> [Self] {
        return Card.all2.filter { $0.weather != nil }
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

        case doubleSpyPower = "double_spy_power"
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

    enum CombatRow: String, CaseIterable, Codable {
        case close, agile, ranged, siege
    }

    enum Faction: String, CaseIterable, Codable {
        case nilfgaard, northern, monsters, scoiatael, neutral
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
}

extension Card {
    static func getSoundAsset(weather: Card.Weather) -> SoundManager.SoundName {
        switch weather {
        case .bitingFrost:
            return .frost
        case .impenetrableFog:
            return .fog
        case .torrentialRain:
            return .rain1
        case .clearWeather:
            return .clearWeather
        }
    }
}
