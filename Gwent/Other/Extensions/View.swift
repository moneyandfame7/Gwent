//
//  View.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 15.01.2024.
//

import SwiftUI

extension View {
    @ViewBuilder
    func textBorder() -> some View {
        let view = self

        view
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
            .shadow(radius: 0.4)
    }
}
