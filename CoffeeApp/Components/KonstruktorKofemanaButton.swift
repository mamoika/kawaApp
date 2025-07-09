import SwiftUI

struct KonstruktorKofemanaButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.title2)
                    .foregroundColor(.white)
                Text("Konstruktor kofemana")
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(18)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
    }
}
