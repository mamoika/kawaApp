import SwiftUI

struct PlaceAndVolumePicker: View {
    @Binding var volume: Int

    let volumes = [250, 350, 450]
    let iconSizes: [Int: CGFloat] = [250: 32, 350: 40, 450: 48]

    var body: some View {
        let badgeTexts: [Int: String] = [
            250: "",
            350: "+1 zł",
            450: "+2 zł"
        ]
        VStack(spacing: 24) {
            Text("Objętość, ml")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            HStack(spacing: 32) {
                ForEach(volumes, id: \.self) { vol in
                    Button(action: {
                        volume = vol
                    }) {
                        VStack(spacing: 4) {
                            if let badge = badgeTexts[vol], !badge.isEmpty {
                                Text(badge)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                                    .offset(y: -2)
                            } else {
                                Spacer().frame(height: 18) // wyrównanie wysokości
                            }
                            Image(systemName: "cup.and.saucer")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: iconSizes[vol]!, height: iconSizes[vol]!)
                                .foregroundColor(volume == vol ? .blue : .gray.opacity(0.3))
                            Text("\(vol)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(volume == vol ? .blue : .gray.opacity(0.3))
                        }
                        .frame(width: 56)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
