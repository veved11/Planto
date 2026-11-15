import SwiftUI

struct AppButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {

        if #available(iOS 26.0, *) {

            configuration.label
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 280, height: 42)
                .contentShape(Capsule())
                .glassEffect(
                    .regular
                        .tint(Color(hex: 0x338069))
                        .interactive(),
                    in: Capsule()
                )
                .scaleEffect(configuration.isPressed ? 0.97 : 1)

        } else {

            configuration.label
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 280, height: 42)
                .contentShape(Capsule())
                .background(
                    Color(hex: 0x338069),
                    in: Capsule()
                )
                .overlay {
                    Capsule()
                        .stroke(.white.opacity(0.96), lineWidth: 1)
                }
                .scaleEffect(configuration.isPressed ? 0.97 : 1)
        }
    }
}
