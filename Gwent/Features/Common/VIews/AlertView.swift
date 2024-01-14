//
//  AlertView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 09.01.2024.
//

import SwiftUI
import UIKit


struct AlertView: View {
    @Binding var alert: AlertItem?

    @State private var offset: CGFloat = -20

    @State private var opacity: CGFloat = 0

    private var contentView: some View {
        VStack(spacing: 0) {
            HStack {
                Text(alert!.title)
                    .opacity(0.7)
                    .foregroundStyle(.brandYellowSecondary)
                    .font(.custom("Gwent", size: 14))
            }
            .frame(maxWidth: .infinity)
            Divider()
                .background(.gray.gradient)
                .padding(.vertical, 8)
            VStack {
                Text(alert!.description)
                    .opacity(0.9)
                    .multilineTextAlignment(.center)
                    .font(.custom("PTSans-Regular", size: 14))
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .padding(.bottom, 30)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(.black)
        .clipShape(.rect(cornerRadius: 4))
        .overlay {
            RoundedRectangle(cornerRadius: 4).stroke(.brandYellowSecondary.opacity(0.2).gradient, lineWidth: 2)
        }
        .padding(.horizontal)
    }

    private var actionsView: some View {
        HStack(spacing: 25) {
            if let confirm = alert?.confirmButton {
                Button(confirm.title) {
                    alert = nil
                    confirm.action()
                    
                }
                .tint(.brandGreen)
                .fontWeight(.bold)
            }

            if let common = alert?.commonButton {
                Button(common.title) {
                    alert = nil
                    common.action()
                    
                }
                .tint(.brandYellowSecondary)
            }

            if let cancel = alert?.cancelButton {
                Button(cancel.title) {
                    alert = nil
                    cancel.action()
                    
                }
                .tint(.red)
            }
        }
        .padding(6)
        .background(.black)
        .font(.custom("PTSans-Regular", size: 14))

        .clipShape(.rect(cornerRadius: 4))
        .overlay {
            RoundedRectangle(cornerRadius: 4).stroke(.brandYellowSecondary.opacity(0.3).gradient, lineWidth: 1)
        }
        .offset(y: 12)
    }

    var body: some View {
        ZStack {
            ZStack(alignment: .bottom) {
                contentView

                actionsView
            }
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.smooth(duration: 0.8)) {
                    offset = 0
                    opacity = 1
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(.ultraThinMaterial)
    }
}

#Preview {
    AlertView(alert: .constant(
        AlertItem(
            title: "Title title TITLE TITLEEEE!!!???777",
            description: "Description",
            cancelButton: ("Cancel", {}),
            commonButton: ("Ok", {}),
            confirmButton: ("Confirm", {})
        )
    ))
}
