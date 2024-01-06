//
//  IconButton.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 27.12.2023.
//

import SwiftUI

struct IconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            Image(systemName: self.systemName)
        }
        .frame(width: 44, height: 44)
        .background(.black.opacity(0.7))
        .clipShape(.rect(cornerRadius: 8))
        .foregroundStyle(.brandYellowSecondary)
    }
}

#Preview {
    IconButton(systemName: "xmark", action: {})
}
