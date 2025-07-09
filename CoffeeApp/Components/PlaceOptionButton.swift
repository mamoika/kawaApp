import SwiftUI

struct PlaceOptionButton: View {
    var isSelected: Bool
    var icon: String
    var label: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .foregroundColor(isSelected ? .blue : .gray.opacity(0.3))
                Text(label)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .gray.opacity(0.3))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
