import SwiftUI

// Gradient dla ognia
extension LinearGradient {
    static var fireGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.yellow, Color.orange, Color.red]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// Arkusz do wyboru pojedynczej opcji
struct OptionSheet: View {
    var title: String
    var options: [String]
    var selected: String
    @Binding var isPresented: Bool
    var onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 16)
                .padding(.bottom, 12)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            onSelect(option)
                            isPresented = false
                        }) {
                            HStack {
                                Text(option)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Spacer()
                                if option == selected {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 20))
                                }
                            }
                            .padding()
                            .background(
                                option == selected ? Color.blue.opacity(0.1) : Color.clear
                            )
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer(minLength: 16)
        }
        .background(Color(.systemBackground))
        .presentationDetents([.height(CGFloat(100 + options.count * 60))])
        .presentationDragIndicator(.hidden)
    }
}

// Arkusz do wielokrotnego wyboru
struct MultiOptionSheet: View {
    var title: String
    var options: [String]
    @Binding var selected: Set<String>
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 16)
                .padding(.bottom, 20)
            
            List(options, id: \.self) { option in
                Button(action: {
                    if selected.contains(option) {
                        selected.remove(option)
                    } else {
                        selected.insert(option)
                    }
                }) {
                    HStack {
                        Text(option)
                            .font(.body)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                        
                        Text("+0.50 zł")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.red)
                            .clipShape(Capsule())
                        
                        if selected.contains(option) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 20))
                                .frame(width: 20, height: 20)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                                .font(.system(size: 20))
                                .frame(width: 20, height: 20)
                        }
                    }
                    .padding(.vertical, 12)
                    .frame(height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .listStyle(PlainListStyle())
            
            Button(action: {
                isPresented = false
            }) {
                Text("Gotowe")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// GŁÓWNY WIDOK KONSTRUKTORA KAWY
struct CoffeeConstructorView: View {
    let selectedCoffee: Coffee
    @EnvironmentObject var cart: CartViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var navigationPath: NavigationPath

    @State private var rodzajKawy: Double = 0.5
    @State private var stopienPalenia: Int = 2
    @State private var mielenie: Int = 1
    @State private var mleko: String = "Brak"
    @State private var syrop: String = "Brak"
    @State private var dodatki: Set<String> = []
    @State private var pokazArkuszMleka = false
    @State private var pokazArkuszSyropu = false
    @State private var pokazArkuszDodatkow = false
    @State private var iloscLodu: Int = 0

    let opcjeMleka = ["Brak", "Krowie", "Bez laktozy", "Odłuszczone", "Owsiane", "Migdałowe", "Kokosowe"]
    let opcjeSyropu = ["Brak", "Amaretto", "Kokos", "Wanilia", "Karmel"]
    let opcjeDodatkow = [
        "Cynamon", "Kardamon", "Imbir", "Kurkuma", "Gałka muszkatołowa", "Kakao", "Miód", "Marshmallow", "Bita śmietana"
    ]

    let fireLevels = [
        (1, "Light roast"),
        (2, "Medium"),
        (3, "Medium-dark"),
        (4, "Dark roast")
    ]
    
    let miejsce: String?
    let objetosc: Int?
    let prepareAtTime: Bool
    let selectedTime: Date
    
    // DODANA POPRAWKA CENY
    var finalPrice: Double {
        let volumePriceMap = [250: 0.0, 350: 1.0, 450: 2.0]
        let volumeExtra = volumePriceMap[objetosc ?? 250] ?? 0.0
        let addonsExtra = Double(dodatki.count) * 0.50
        return selectedCoffee.price + volumeExtra + addonsExtra
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 18) {
                    Text(selectedCoffee.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 12)

                    // Rodzaj kawy
                    CardSection {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rodzaj kawy")
                                .font(.headline)
                            Slider(value: $rodzajKawy, in: 0...1, step: 0.01)
                            HStack {
                                Text("Arabika")
                                    .foregroundColor(rodzajKawy < 0.5 ? .blue : .secondary)
                                Spacer()
                                Text("Robusta")
                                    .foregroundColor(rodzajKawy > 0.5 ? .blue : .secondary)
                            }
                            .font(.caption)
                        }
                    }

                    // Stopień palenia
                    CardSection {
                        VStack(spacing: 20) {
                            Text("Stopień palenia")
                                .font(.headline)
                            HStack(spacing: 0) {
                                ForEach(fireLevels, id: \.0) { level, label in
                                    VStack(spacing: 8) {
                                        Rectangle()
                                            .fill(
                                                stopienPalenia >= level
                                                    ? LinearGradient.fireGradient
                                                    : LinearGradient(
                                                        gradient: Gradient(colors: [Color.gray.opacity(0.15)]),
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                            )
                                            .mask(
                                                Image(systemName: "flame.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                            )
                                            .frame(width: 32, height: 32)
                                            .onTapGesture { stopienPalenia = level }
                                        
                                        Text(label)
                                            .font(.caption)
                                            .fontWeight(stopienPalenia == level ? .bold : .regular)
                                            .foregroundColor(stopienPalenia == level ? .blue : .gray)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }

                    // Mielenie
                    CardSection {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mielenie")
                                .font(.headline)
                            Picker("Mielenie", selection: $mielenie) {
                                Text("Drobne").tag(1)
                                Text("Grube").tag(2)
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    // Mleko
                    CardSection {
                        HStack {
                            Text("Mleko")
                                .font(.headline)
                            Spacer()
                            Button(action: { pokazArkuszMleka = true }) {
                                Text(mleko)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.08))
                                    .cornerRadius(10)
                            }
                        }
                        .sheet(isPresented: $pokazArkuszMleka) {
                            OptionSheet(
                                title: "Wybierz mleko",
                                options: opcjeMleka,
                                selected: mleko,
                                isPresented: $pokazArkuszMleka
                            ) { selected in
                                mleko = selected
                            }
                        }
                    }
                    
                    // Syrop
                    CardSection {
                        HStack {
                            Text("Syrop")
                                .font(.headline)
                            Spacer()
                            Button(action: { pokazArkuszSyropu = true }) {
                                Text(syrop)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.08))
                                    .cornerRadius(10)
                            }
                        }
                        .sheet(isPresented: $pokazArkuszSyropu) {
                            OptionSheet(
                                title: "Wybierz syrop",
                                options: opcjeSyropu,
                                selected: syrop,
                                isPresented: $pokazArkuszSyropu
                            ) { selected in
                                syrop = selected
                            }
                        }
                    }

                    // Dodatki
                    CardSection {
                        HStack {
                            Text("Dodatki")
                                .font(.headline)
                            Spacer()
                            Button(action: { pokazArkuszDodatkow = true }) {
                                HStack(spacing: 6) {
                                    if dodatki.isEmpty {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 16))
                                        Text("Wybierz")
                                            .foregroundColor(.blue)
                                            .font(.body)
                                    } else {
                                        Text("\(dodatki.count) wybrane")
                                            .foregroundColor(.blue)
                                            .font(.body)
                                            .fontWeight(.medium)
                                    }
                                }
                                .lineLimit(1)
                                .frame(minWidth: 80, alignment: .trailing)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.08))
                                .cornerRadius(10)
                            }
                        }
                        .sheet(isPresented: $pokazArkuszDodatkow) {
                            MultiOptionSheet(
                                title: "Wybierz dodatki",
                                options: opcjeDodatkow,
                                selected: $dodatki,
                                isPresented: $pokazArkuszDodatkow
                            )
                        }
                    }

                    // Lód
                    CardSection {
                        HStack {
                            Text("Lód")
                                .font(.headline)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text(iloscLodu == 0 ? "Brak" : iloscLodu == 1 ? "1 kostka" : iloscLodu == 2 ? "2 kostki" : "3 kostki")
                                    .font(.body)
                                    .foregroundColor(iloscLodu == 0 ? .secondary : .blue)
                                    .fontWeight(.medium)
                                    .animation(.easeInOut(duration: 0.2), value: iloscLodu)
                                
                                Button(action: {
                                    iloscLodu = (iloscLodu + 1) % 4
                                }) {
                                    HStack(spacing: 4) {
                                        ForEach(0..<3, id: \.self) { index in
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(
                                                    index < iloscLodu
                                                        ? Color.blue
                                                        : Color.gray.opacity(0.15)
                                                )
                                                .frame(width: 18, height: 18)
                                                .animation(.easeInOut(duration: 0.2), value: iloscLodu)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.08))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }

                    Spacer(minLength: 120) // miejsce na sticky bottom bar
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }

            // Sticky bottom bar: suma do zapłaty i przycisk w białym tle
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    // Suma do zapłaty - zawsze widoczna
                    HStack {
                        Text("Suma do zapłaty")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.2f zł", finalPrice))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 18)
                    .padding(.bottom, 14)

                    Button(action: {
                        let finalnaKena = finalPrice
                        
                        let zamowienie = CoffeeOrder(
                            nazwaKawy: "\(selectedCoffee.name) Custom",
                            image: selectedCoffee.image,
                            price: finalnaKena,
                            rodzajKawy: rodzajKawy < 0.5 ? "Arabika" : "Robusta",
                            stopienPalenia: stopienPalenia,
                            mielenie: mielenie,
                            mleko: mleko,
                            syrop: syrop,
                            dodatki: Array(dodatki),
                            iloscLodu: iloscLodu,
                            miejsce: miejsce,
                            objetosc: objetosc,
                            prepareAtTime: prepareAtTime,
                            selectedTime: selectedTime
                        )
                        cart.addOrder(zamowienie)
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            navigationPath.append(AppRoute.cart)
                        }
                    }) {
                        Text("Dodaj do koszyka z dodatkami")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(18)
                            .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 24)
                }
                .background(
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -2)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(selectedCoffee.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Pomocniczy widok karty (sekcji)
struct CardSection<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
    }
}
