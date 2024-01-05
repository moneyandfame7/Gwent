//
//  HornOverlayView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 04.01.2024.
//

import SwiftUI

struct HornOverlayView: View {
    @State private var opacityMain: CGFloat = 1
    @State private var opacity: CGFloat = 0
    @State private var offset: CGFloat = 0

    var body: some View {
        ZStack {
            Image(.Overlay.horn)
                .resizable()
            Image(.Overlay.horn)
                .resizable()
                .offset(x: -25, y: offset)
                .opacity(opacity)
        }
        .opacity(opacityMain)
        .frame(maxHeight: 75)
        .onAppear {
            Task {
                withAnimation(.smooth(duration: 2)) {
                    offset = -4
                    opacity = 1
                }
                try? await Task.sleep(for: .seconds(0.8))

                withAnimation(.smooth(duration: 1.5)) {
                    offset = 0
                    opacity = 0
                }

                try? await Task.sleep(for: .seconds(0.5))

                withAnimation(.smooth(duration: 1.5)) {
                    offset = -4
                    opacity = 1
                }

                try? await Task.sleep(for: .seconds(0.4))

                withAnimation(.smooth(duration: 1.5)) {
                    offset = 0
                    opacity = 0

                    opacityMain = 0
                }
            }
        }
    }
}

#Preview {
    HornOverlayView()
}
