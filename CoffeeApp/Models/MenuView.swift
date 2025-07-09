import SwiftUI

struct MenuView: View {
    @StateObject var cart = CartViewModel()
    @State private var navigationPath = NavigationPath()
    let selectedCafe: CafeAddress
    
    let coffees: [Coffee] = [
        Coffee(name: "Americano", image: "americano", price: 11.99),
        Coffee(name: "Cappuccino", image: "cappuccino", price: 13.99),
        Coffee(name: "Latte", image: "latte", price: 14.99),
        Coffee(name: "Flat White", image: "flatwhite", price: 14.99),
        Coffee(name: "Chmurka", image: "raf", price: 15.99),
        Coffee(name: "Espresso", image: "espresso", price: 9.99)
    ]
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Pasek z adresem kawiarni na górze - iOS 18 style
                HStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text(selectedCafe.address)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
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
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.bottom, 12)

                Spacer() // Górny spacer

                VStack(spacing: 28) {
                    Text("Wybierz swoją kawę")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(coffees) { coffee in
                            CoffeeCardView(coffee: coffee) {
                                navigationPath.append(AppRoute.orderDetail(coffee))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Koszyk - iOS 18 style
                    CartButtonView(cart: cart) {
                        navigationPath.append(AppRoute.cart)
                    }
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: 500)
                .padding(.horizontal)

                Spacer() // Dolny spacer
            }
            .background(Color.white) // Białe tło
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .orderDetail(let coffee):
                    OrderDetailView(coffee: coffee, navigationPath: $navigationPath)
                        .environmentObject(cart)
                case .cart:
                    CartView(navigationPath: $navigationPath)
                        .environmentObject(cart)
                case .payment(let prepareAtTime, let selectedTime):  // Naprawiony case z parametrami
                    PaymentView(
                        navigationPath: $navigationPath,
                        prepareAtTime: prepareAtTime,
                        selectedTime: selectedTime
                    )
                    .environmentObject(cart)
                }
            }
        }
    }
}

// Nowoczesna karta kawy - iOS 18 style
struct CoffeeCardView: View {
    let coffee: Coffee
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(0.08),
                        radius: isPressed ? 8 : 12,
                        x: 0,
                        y: isPressed ? 3 : 6
                    )
                    .frame(height: 160)
                
                VStack(spacing: 10) {
                    Spacer(minLength: 12)
                    Image(coffee.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 65)
                    Text(coffee.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Spacer(minLength: 12)
                }
                .padding(.top, 18)
                
                // Badge z ceną - iOS 18 style
                VStack {
                    HStack {
                        Spacer()
                        Text(String(format: "%.2f zł", coffee.price))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
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
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                            .padding([.top, .trailing], 12)
                    }
                    Spacer()
                }
            }
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// Nowoczesny przycisk koszyka - iOS 18 style
struct CartButtonView: View {
    let cart: CartViewModel
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Koszyk")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.blue)
                        .shadow(
                            color: Color.blue.opacity(0.3),
                            radius: isPressed ? 6 : 10,
                            x: 0,
                            y: isPressed ? 2 : 4
                        )
                )
                .foregroundColor(.white)
                .scaleEffect(isPressed ? 0.96 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isPressed)
            }
            .buttonStyle(PlainButtonStyle())
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
            
            // Badge z liczbą przedmiotów
            if cart.items.count > 0 {
                Text("\(cart.items.count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.red)
                            .shadow(color: Color.red.opacity(0.4), radius: 4, x: 0, y: 2)
                    )
                    .offset(x: 12, y: -8)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: cart.items.count)
    }
}
