//
//  PassedView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 18.01.2024.
//

import SwiftUI

struct PassedView: View {
    var reversed = false
    
    @State private var animated = false

    var body: some View {
        ZStack(alignment: reversed ? .bottom : .top) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .mask {
                    VStack(spacing: 0) {
                        LinearGradient(colors: [
                            Color.black.opacity(1),

                            Color.black.opacity(0),
                        ],
                        startPoint: .bottom,
                        endPoint: .top)
                        Rectangle()
                    }
                }
                .frame(height: .infinity)
                .opacity(animated ? 1 : 0)
                .rotationEffect(.degrees(reversed ? 180 : 0))

            if animated {
                Text("Passed")
                    .font(.custom("Gwent", size: 22, relativeTo: .title3))
                    .textBorder()
                    .transition(.move(edge: reversed ? .top : .bottom).combined(with: .opacity))
                    
                    .padding(.vertical, 15)
            }
        }
        
        .onAppear {
            withAnimation {
                animated = true
            }
        }
    }
}

#Preview {
    HStack {
        ForEach(0 ... 10, id: \.self) { i in

            Rectangle()
                .frame(height: 100)
        }
    }

    .frame(maxWidth: .infinity)
    .overlay(alignment: .bottom) {
        PassedView()
    }
    .environment(\.colorScheme, .dark)
}
