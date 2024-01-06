//
//  Hui.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import Foundation

// import Observation

@Observable
final class Card: Identifiable {
    // MARK: - JSON Data -

    let id: Int
    let name: String
    let image: String
    let price: Int?
    let power: Int?
    let copies: Int?
    let type: Card.CardType
    let ability: Card.Ability?
    let leaderAbility: Card.LeaderAbility?
    var combatRow: Card.Row?
    let faction: Card.Faction
    let weather: Card.Weather?

    // MARK: - End JSON Data -

    var editedPower: Int?
    var holderIsBot: Bool?
    var shouldAnimate = false

    var animateAs: Card.Animation?

    init(
        id: Int,
        name: String,
        image: String,
        price: Int?,
        power: Int?,
        copies: Int?,
        type: Card.CardType,
        ability: Card.Ability?,
        leaderAbility: Card.LeaderAbility?,
        combatRow: Card.Row?,
        faction: Card.Faction,
        weather: Card.Weather?
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.price = price
        self.power = power
        self.copies = copies
        self.type = type
        self.ability = ability
        self.leaderAbility = leaderAbility
        self.combatRow = combatRow
        self.faction = faction
        self.weather = weather
    }

    // MARK: обовʼязково стежити, що вказав в опціональних типах "?", ex: Hui.Ability?.self

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        image = try container.decode(String.self, forKey: .image)
        price = try container.decode(Int?.self, forKey: .price)

        power = try container.decode(Int?.self, forKey: .power)
        copies = try container.decode(Int?.self, forKey: .copies)
        faction = try container.decode(Card.Faction.self, forKey: .faction)
        type = try container.decode(Card.CardType.self, forKey: .type)

        ability = try container.decode(Card.Ability?.self, forKey: .ability)
        leaderAbility = try container.decode(Card.LeaderAbility?.self, forKey: .leaderAbility)
        combatRow = try container.decode(Card.Row?.self, forKey: .combatRow)
        weather = try container.decode(Card.Weather?.self, forKey: .weather)
    }
}

extension Card {
    static let allTest: [Card] = DataManager.shared.load("cards.json")

    // щоб уникнути мутування масиву треба повертати нові екземпляри завжди
    static func all() -> [Card] { DataManager.shared.load("cards.json") }

    static func inHand() -> [Card] { Array(Card.all()[0 ..< 10]) }

    static func leader() -> Card { .all()[59] }

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

    @MainActor
    func animate(_ animation: Card.Animation? = nil) async {
        shouldAnimate = true
        animateAs = animation

        try? await Task.sleep(for: .seconds(2))

        shouldAnimate = false
        animateAs = nil
    }
}

extension Card: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, image, price, power, copies, type, ability
        case leaderAbility = "leader_ability"
        case combatRow = "combat_row"
        case faction, weather
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(image, forKey: .image)
        try container.encode(price, forKey: .price)

        try container.encode(power, forKey: .power)
        try container.encode(copies, forKey: .copies)
        try container.encode(faction, forKey: .faction)
        try container.encode(type, forKey: .type)

        try container.encode(ability, forKey: .ability)
        try container.encode(leaderAbility, forKey: .leaderAbility)
        try container.encode(combatRow, forKey: .combatRow)
        try container.encode(weather, forKey: .weather)
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

    enum Faction: String, CaseIterable, Codable {
        case nilfgaard, northern, monsters, scoiatael, neutral
    }

    enum Row: String, CaseIterable, Codable {
        case close, agile, ranged, siege
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

    enum Animation: String, CaseIterable, Codable {
        case scorch, medic
    }
}
