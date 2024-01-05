//
//  BrandButton.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 29.12.2023.
//

import SwiftUI

struct BrandButton: View {
    var title: String
    var disabled: Bool

    init(_ title: String = "", disabled: Bool = false) {
        self.title = title
        self.disabled = disabled
    }

    var body: some View {
        Button(title) {}
            .frame(minWidth: 80, minHeight: 35)
            .padding(3)
            .background(.black.gradient.opacity(0.7))
            .clipShape(.rect(cornerRadius: 8))
            .foregroundStyle(.brandYellow.opacity(disabled ? 0.3 : 1))
            .fontWeight(.bold)
            .disabled(disabled)
    }
}

#Preview {
    BrandButton("Pass")
}
