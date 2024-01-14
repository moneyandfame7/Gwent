//
//  RainView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 21.12.2023.
//

import AVKit
import SwiftUI

struct RainView: View {
    var body: some View {
        Image(.Weathers.overlayRain).resizable()
    }
}

#Preview {
    RainView()
}
