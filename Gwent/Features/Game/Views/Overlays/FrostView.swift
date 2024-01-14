//
//  FrostView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 21.12.2023.
//

import SwiftUI

struct FrostView: View {
    var body: some View {
        Image(.Weathers.overlayFrost).resizable()
    }
}

#Preview {
    HStack {
        FrostView()
    }
    .frame(maxHeight: 100)
    .background(Image(.Assets.texture2))
}
