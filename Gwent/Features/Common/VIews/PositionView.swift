//
//  PositionView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 16.01.2024.
//

import SwiftUI

struct PositionView: View {
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    HStack {
                        VStack {
                            Text("\(geometry.size.width) X \(geometry.size.height)")
                            Spacer().frame(height: geometry.size.height)
                        }
                        Spacer()
                    }
                    Divider()
                        .background(.red)
                    
                    HStack {
                        Divider()
                            .background(.red)
                    }
                    
                    Circle()
                        .frame(width: 50, height: 50)
                        .border(.red)
                        .position(x: 100, y: geometry.size.height  / 2)
                }
            }
        }
        .frame(width: 200, height: 200)
        .ignoresSafeArea()
    }
}

#Preview {
    PositionView()
}
