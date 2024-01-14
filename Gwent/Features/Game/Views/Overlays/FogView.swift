//
//  FogView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 21.12.2023.
//

import SwiftUI

struct FogView: View {
    var body: some View {
        Image(.Weathers.overlayFog).resizable()
    }
}

#Preview {
    HStack {
        FogView()
    }
    .frame(maxHeight: 100)
    .background(.white)
}
