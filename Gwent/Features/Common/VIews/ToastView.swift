//
//  ToastView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 24.01.2024.
//

import SwiftUI

struct ToastView: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
                .font(.custom(AppFont.PTSans.rawValue, size: 16))
                .foregroundStyle(.black)
        }
        .frame(minWidth: 100, minHeight: 40)
        .padding(.horizontal)
        .background(.toastBackground)
        .overlay {
            Rectangle().stroke(.gray, lineWidth: 1)
                .padding(2)
        }
    }
}

#Preview {
    ToastView(text: "asdasd")
}

struct ToastModifier: ViewModifier {
    @Binding var text: String?

    func body(content: Content) -> some View {
        ZStack(alignment: .bottomLeading) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            /// VStack потрібно використовувати, бо є трабли з анімацією)))
            VStack {
                toastBody()
                    .onChange(of: text) { old, new in

                        if old != nil {
                            return
                        }

                        hideToast()
                    }
                    .animation(.smooth, value: text)
                    .transition(.offset(x: -30).combined(with: .opacity.animation(.smooth)))
            }
        }
    }

    @ViewBuilder
    private func toastBody() -> some View {
        if let text {
            ToastView(text: text)
                .offset(x: 40, y: -10)
        }
    }

    private func hideToast() {
        guard text != nil else { return }

        SoundManager.shared.playSound(sound: .toast)
        HapticManager.shared.trigger(.notification(.warning))
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))

            withAnimation {
                self.text = nil
            }
        }
    }
}

extension View {
    func toast(text: Binding<String?>) -> some View {
        modifier(ToastModifier(text: text))
    }
}

#Preview {
    @State var text: String? = nil

    return VStack {
        Button("Show toast") {
            text = Date.now.formatted()
        }
    }
    .toast(text: $text)
}
