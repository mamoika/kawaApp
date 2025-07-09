import SwiftUI

struct CartView: View {
    @EnvironmentObject var cart: CartViewModel
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack(spacing: 0) {
            if cart.items.isEmpty {
                EmptyCartView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(cart.items) { zamowienie in
                            CartItemView(zamowienie: zamowienie) {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    cart.removeOrder(zamowienie)
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120) // Miejsce na sticky bottom bar
                }
            }

            // Sticky bottom bar - iOS 18 style
            if !cart.items.isEmpty {
                CartSummaryView(
                    totalPrice: cart.items.reduce(0) { $0 + $1.price },
                    navigationPath: $navigationPath,
                    cart: cart  // Przekaż cart do pobrania informacji o czasie
                )
            }
        }
        .background(Color.white.ignoresSafeArea()) // Białe tło
        .navigationTitle("Mój koszyk")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    navigationPath = NavigationPath()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Wybór kawy")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// Pusty koszyk - iOS 18 style
struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "cart")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.gray.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("Koszyk jest pusty")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Dodaj swoją ulubioną kawę")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// Karta przedmiotu w koszyku - iOS 18 style
struct CartItemView: View {
    let zamowienie: CoffeeOrder
    let onRemove: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Ikona kawy z informacjami pod spodem
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .frame(width: 80, height: 80)
                    
                    Image(zamowienie.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                
                // Miejsce i objętość pod ikoną
                VStack(spacing: 2) {
                    if let miejsce = zamowienie.miejsce {
                        Text(miejsce)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    if let objetosc = zamowienie.objetosc {
                        Text("\(objetosc) ml")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Informacje o zamówieniu
            VStack(alignment: .leading, spacing: 8) {
                Text(zamowienie.nazwaKawy)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 4) {
                    DetailRow(label: "Rodzaj", value: zamowienie.rodzajKawy)
                    DetailRow(label: "Palenie", value: opisStopniaPalenia(zamowienie.stopienPalenia))
                    DetailRow(label: "Mielenie", value: zamowienie.mielenie == 1 ? "Drobne" : "Grube")
                    
                    if zamowienie.mleko != "Brak" {
                        DetailRow(label: "Mleko", value: zamowienie.mleko)
                    }
                    
                    if zamowienie.syrop != "Brak" {
                        DetailRow(label: "Syrop", value: zamowienie.syrop)
                    }
                    
                    if zamowienie.iloscLodu > 0 {
                        DetailRow(label: "Lód", value: lodOpis(zamowienie.iloscLodu))
                    }
                    
                    if !zamowienie.dodatki.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dodatki:")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            ForEach(zamowienie.dodatki, id: \.self) { dodatek in
                                HStack(spacing: 4) {
                                    Text("•")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text(dodatek)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .layoutPriority(1)
            
            Spacer(minLength: 8)
            
            // Cena i przycisk usuwania
            VStack(alignment: .trailing, spacing: 12) {
                Text(String(format: "%.2f zł", zamowienie.price))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 182/255, green: 113/255, blue: 255/255),
                                Color(red: 255/255, green: 105/255, blue: 180/255)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                
                Button(action: onRemove) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(width: 36, height: 36)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    isPressed = pressing
                }, perform: {})
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
    }
    
    func opisStopniaPalenia(_ stopien: Int) -> String {
        switch stopien {
        case 1: return "Light roast"
        case 2: return "Medium"
        case 3: return "Medium-dark"
        case 4: return "Dark roast"
        default: return "Medium"
        }
    }
    
    func lodOpis(_ ilosc: Int) -> String {
        switch ilosc {
        case 1: return "1 kostka"
        case 2: return "2 kostki"
        case 3: return "3 kostki"
        default: return "\(ilosc) kostki"
        }
    }
}

// Wiersz szczegółów - iOS 18 style
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Text("\(label):")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// Podsumowanie koszyka - iOS 18 style
struct CartSummaryView: View {
    let totalPrice: Double
    @Binding var navigationPath: NavigationPath
    let cart: CartViewModel  // Dodano cart
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Łączna suma")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f zł", totalPrice))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {
                    // Pobierz informacje o czasie z pierwszego zamówienia
                    let firstOrder = cart.items.first
                    let prepareAtTime = firstOrder?.prepareAtTime ?? false
                    let selectedTime = firstOrder?.selectedTime ?? Date()
                    
                    navigationPath.append(AppRoute.payment(prepareAtTime: prepareAtTime, selectedTime: selectedTime))
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Dalej")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 182/255, green: 113/255, blue: 255/255),
                                Color(red: 255/255, green: 105/255, blue: 180/255)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -4)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
}
