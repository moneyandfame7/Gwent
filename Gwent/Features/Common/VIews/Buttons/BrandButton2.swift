//
//  BrandButton2.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 15.01.2024.
//

import SwiftUI

struct BrandButton2: View {
    let title: String
    var disabled: Bool = false
    let action: () -> Void

    

    var body: some View {
        Button(title, action: action)
            .padding(.vertical, 10)
            .padding(.horizontal, 24)
            .border(.brandYellowSecondary.opacity(0.6), width: 3)
            .overlay {
                RoundedRectangle(cornerRadius: 2)
                    .stroke(.black, lineWidth: 3)
            }
            .background(.buttonBackground)
            .foregroundStyle( disabled ? .white.opacity(0.7) : .white)
            .font(.custom("Gwent", size: 16))
            .textCase(.uppercase)
            .shadow(radius: 1)
            .disabled(disabled)
    }
}

#Preview {
    VStack {
        BrandButton2(title: "Title") {
            print("Clicked")
        }
        BrandButton2(title: "Title", disabled: true) {
            print("Clicked")
        }
    }
}
