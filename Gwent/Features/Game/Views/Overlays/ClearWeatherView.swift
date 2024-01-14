//
//  SunView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 21.12.2023.
//

import SwiftUI

struct ClearWeatherView: View {
    @State private var offset = 0.0
    @State private var opacity = 0.0

    var body: some View {
        Image(.Weathers.sunlightOther2)
            .resizable()
            .scaledToFit()
            .frame(width: 500, height: 500)
//            .opacity(0.7)
            .offset(x: offset, y: -150)
            .opacity(opacity)
            .onAppear {
                Task {
                    withAnimation(.linear(duration: 0.3)) {
                        opacity = 1
                    }
                    withAnimation(.linear(duration: 3)) {
                        offset = 150
                    }

                    try await Task.sleep(for: .seconds(2))

                    withAnimation(.linear(duration: 0.5)) {
                        opacity = 0
                    }
                }
            }
    }
}

#Preview {
    ClearWeatherView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Image(.Assets.texture).resizable().scaledToFill())
}
