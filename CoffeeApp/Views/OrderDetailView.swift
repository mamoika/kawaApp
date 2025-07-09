import SwiftUI

struct OrderDetailView: View {
    let coffee: Coffee
    @EnvironmentObject var cart: CartViewModel
    @Binding var navigationPath: NavigationPath
    @State private var ilość = 1
    @State private var miejsce = "Na miejscu"
    @State private var objętość = 250
    @State private var prepareAtTime = false
    @State private var time = Date()
    @State private var pokazKonstruktor = false

    func calculateTotalPrice() -> Double {
        let volumePriceMap = [250: 0.0, 350: 1.0, 450: 2.0]
        let extra = volumePriceMap[objętość] ?? 0.0
        return (coffee.price + extra) * Double(ilość)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Ikona kawy - iOS 18 style
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(.secondarySystemGroupedBackground))
                            .frame(width: 140, height: 140)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        
                        Image(coffee.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 80)
                    }
                    .padding(.top, 20)
                    
                    Text(coffee.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                

                    // Miejsce - iOS 18 style
                    ModernCardSection {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 16) {
                                ModernPlaceButton(
                                    isSelected: miejsce == "Na miejscu",
                                    icon: "cup.and.saucer.fill",
                                    label: "Na miejscu"
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        miejsce = "Na miejscu"
                                    }
                                }
                                
                                ModernPlaceButton(
                                    isSelected: miejsce == "Na wynos",
                                    icon: "takeoutbag.and.cup.and.straw.fill",
                                    label: "Na wynos"
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        miejsce = "Na wynos"
                                    }
                                }
                            }
                        }
                    }

                    // Objętość - iOS 18 style
                    ModernCardSection {
                        PlaceAndVolumePicker(volume: $objętość)
                    }

                    // Konstruktor - iOS 18 style
                    ModernCardSection {
                        VStack(spacing: 16) {
                            Text("Personalizacja")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                pokazKonstruktor = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("Konstruktor Kofemana")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
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
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                    .sheet(isPresented: $pokazKonstruktor) {
                        CoffeeConstructorView(
                            selectedCoffee: coffee,
                            navigationPath: $navigationPath,  // Przenieś przed miejsce
                            miejsce: miejsce,
                            objetosc: objętość,
                            prepareAtTime: prepareAtTime,    // Przekaż
                            selectedTime: time
                        )
                        .environmentObject(cart)
                    }

                    // Czas przygotowania - iOS 18 style
                    ModernCardSection {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Przygotować na określoną godzinę?", isOn: $prepareAtTime)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                            
                            if prepareAtTime {
                                DatePicker("Godzina", selection: $time, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: prepareAtTime)

                    Spacer(minLength: 120) // miejsce na sticky bottom bar
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }

            // Sticky bottom bar - iOS 18 style
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    HStack {
                        Text("Suma do zapłaty")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.2f zł", calculateTotalPrice()))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                    Button(action: {
                        let volumePriceMap = [250: 0.0, 350: 1.0, 450: 2.0]
                        let extra = volumePriceMap[objętość] ?? 0.0
                        let finalPrice = coffee.price + extra
                        let zamowienie = CoffeeOrder(
                            nazwaKawy: coffee.name,
                            image: coffee.image,
                            price: finalPrice,
                            rodzajKawy: "Klasyczna",
                            stopienPalenia: 3,
                            mielenie: 1,
                            mleko: "Brak",
                            syrop: "Brak",
                            dodatki: [],
                            iloscLodu: 0,
                            miejsce: miejsce,
                            objetosc: objętość,
                            prepareAtTime: prepareAtTime,    // Dodaj
                            selectedTime: time
                        )
                        for _ in 0..<ilość {
                            cart.addOrder(zamowienie)
                        }
                        navigationPath.append(AppRoute.cart)
                    }) {
                        Text("Dodaj do koszyka")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 28)
                }
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -4)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Zamówienie")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Nowoczesna karta sekcji - iOS 18 style
struct ModernCardSection<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}

// Nowoczesny przycisk miejsca - iOS 18 style
struct ModernPlaceButton: View {
    let isSelected: Bool
    let icon: String
    let label: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .blue)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.blue : Color.blue.opacity(0.08))
                    .shadow(
                        color: isSelected ? Color.blue.opacity(0.3) : Color.clear,
                        radius: isSelected ? 8 : 0,
                        x: 0,
                        y: isSelected ? 4 : 0
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
