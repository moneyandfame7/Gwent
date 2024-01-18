//
//  AbilityView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 16.01.2024.
//

import SwiftUI

struct AbilityView: View {
    let card: Card

    @ViewBuilder
    private func commonAbilityView(ability: Card.Ability) -> some View {
        let abilityInfo = Ability.all[ability.rawValue]!

        VStack(spacing: 15) {
            Text(abilityInfo.name)
                .font(.custom("Gwent", size: 28, relativeTo: .title))
                .foregroundStyle(.brandYellowSecondary)
            Text(abilityInfo.description)
                .font(.custom("PTSans-Regular", size: 16, relativeTo: .body))
                .foregroundStyle(.brandYellowSecondary)
        }
        .frame(maxWidth: .infinity)
        .background(.black.opacity(0.8))
        .overlay(alignment: .topLeading) {
            Image("Abilities/\(ability.rawValue)")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        }
        .safeAreaPadding(10)
        .padding(.bottom, 50)
    }

    @ViewBuilder
    private func leaderAbilityView(ability: Card.LeaderAbility) -> some View {
        let text = Ability.leaders[ability.rawValue]!

        VStack(spacing: 0) {
            Text(text)
                .font(.custom("Gwent", size: 16, relativeTo: .body))
                .multilineTextAlignment(.center)
                .foregroundStyle(.brandYellowSecondary)
        }
        .frame(maxWidth: .infinity)
        .background(.black.opacity(0.8))
        .safeAreaPadding(25)
        .padding(.bottom, 50)
    }

    var body: some View {
        if let leaderAbility = card.leaderAbility {
            leaderAbilityView(ability: leaderAbility)
        } else if let ability = card.ability {
            commonAbilityView(ability: ability)
        }
    }
}

#Preview {
    AbilityView(card: Card.leader)
}
