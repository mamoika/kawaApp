import SwiftUI

struct CafeAddress: Identifiable, Equatable {
    let id = UUID()
    let address: String
    let distance: String
    let isOpen: Bool
}

struct CafeSelectionView: View {
    let onSelect: (CafeAddress) -> Void
    let cafes = [
        CafeAddress(address: "ul. Wojska Polskiego 46, Szczecin", distance: "0.3 km", isOpen: true),
        CafeAddress(address: "ul. Jagiellońska 36, Szczecin", distance: "0.8 km", isOpen: true),
        CafeAddress(address: "ul. Krzywoustego 63, Szczecin", distance: "1.2 km", isOpen: false),
        CafeAddress(address: "al. Piastów 30, Szczecin", distance: "1.5 km", isOpen: true),
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Białe tło
                Color.white
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    
                    VStack(spacing: 32) {
                        // Header z ikoną i tytułem - wyśrodkowany
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 182/255, green: 113/255, blue: 255/255),
                                                Color(red: 255/255, green: 105/255, blue: 180/255)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color(red: 182/255, green: 113/255, blue: 255/255).opacity(0.3), radius: 12, x: 0, y: 6)
                                
                                Image(systemName: "location.fill")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Wybierz kawiarnię")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("Znajdź najbliższą lokalizację")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }


                        // Lista kawiarni - wyśrodkowana
                        VStack(spacing: 16) {
                            ForEach(cafes) { cafe in
                                CafeCardView(cafe: cafe) {
                                    onSelect(cafe)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationBarHidden(true)
        }
    }
}

// Nowoczesna karta kawiarni
struct CafeCardView: View {
    let cafe: CafeAddress
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Ikona kawiarni
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    cafe.isOpen ? Color.green.opacity(0.1) : Color.red.opacity(0.1),
                                    cafe.isOpen ? Color.green.opacity(0.05) : Color.red.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(cafe.isOpen ? .green : .red)
                }
                
                // Informacje o kawiarni
                VStack(alignment: .leading, spacing: 6) {
                    Text(cafe.address)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 12) {
                        // Status
                        HStack(spacing: 4) {
                            Circle()
                                .fill(cafe.isOpen ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            Text(cafe.isOpen ? "Otwarte" : "Zamknięte")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(cafe.isOpen ? .green : .red)
                        }
                        
                        // Odległość
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(cafe.distance)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Strzałka
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(0.06),
                        radius: isPressed ? 8 : 12,
                        x: 0,
                        y: isPressed ? 2 : 4
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .disabled(!cafe.isOpen)
        .opacity(cafe.isOpen ? 1.0 : 0.7)
    }
}

// Extension dla zaokrąglonych rogów
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
