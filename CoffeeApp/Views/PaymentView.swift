import SwiftUI

struct PaymentView: View {
    @EnvironmentObject var cart: CartViewModel
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) private var dismiss
    
    let prepareAtTime: Bool
    let selectedTime: Date
    
    @State private var selectedPaymentMethod = "apple"
    @State private var showingSuccess = false
    @State private var isProcessing = false
    
    let paymentMethods = [
        ("apple", "Apple Pay", "applelogo"),
        ("blik", "BLIK", "qrcode"),
        ("sber", "Gotówka", "rublesign.circle.fill"),
    ]
    
    var totalPrice: Double {
        cart.items.reduce(0) { $0 + $1.price }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header z ikoną płatności
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
                                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                            
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Płatność")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Wybierz metodę płatności")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Podsumowanie zamówienia
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Podsumowanie zamówienia")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ForEach(cart.items.prefix(3)) { item in
                            HStack {
                                Text(item.nazwaKawy)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(String(format: "%.2f zł", item.price))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if cart.items.count > 3 {
                            Text("i \(cart.items.count - 3) więcej...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Łącznie")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            Text(String(format: "%.2f zł", totalPrice))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    )
                    
                    // Metody płatności
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Metoda płatności")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            ForEach(paymentMethods, id: \.0) { method in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedPaymentMethod = method.0
                                    }
                                }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: method.2)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(selectedPaymentMethod == method.0 ? .white : .blue)
                                            .frame(width: 24)
                                        
                                        Text(method.1)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(selectedPaymentMethod == method.0 ? .white : .primary)
                                        
                                        Spacer()
                                        
                                        if selectedPaymentMethod == method.0 {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(selectedPaymentMethod == method.0 ? Color.blue : Color.blue.opacity(0.06))
                                            .shadow(
                                                color: selectedPaymentMethod == method.0 ? Color.blue.opacity(0.3) : Color.clear,
                                                radius: selectedPaymentMethod == method.0 ? 8 : 0,
                                                x: 0,
                                                y: selectedPaymentMethod == method.0 ? 4 : 0
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    )
                    
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 20)
            }
            
            // Sticky bottom bar z przyciskiem płatności
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    HStack {
                        Text("Do zapłaty")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.2f zł", totalPrice))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    Button(action: {
                        processPayment()
                    }) {
                        HStack(spacing: 8) {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: paymentIcon)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            Text(isProcessing ? "Przetwarzanie..." : paymentButtonText)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 24)
                    }
                    .disabled(isProcessing)
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
        .navigationTitle("Płatność")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Koszyk")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingSuccess) {
            PaymentSuccessView(
                navigationPath: $navigationPath,
                prepareAtTime: prepareAtTime,
                selectedTime: selectedTime
            )
        }
        .animation(.easeInOut(duration: 0.3), value: selectedPaymentMethod)
    }
    
    var paymentButtonText: String {
        switch selectedPaymentMethod {
        case "apple": return "Zapłać Apple Pay"
        case "blik": return "Zapłać BLIK"
        case "sber": return "Zapłać Gotówką"
        default: return "Zapłać"
        }
    }
    
    var paymentIcon: String {
        switch selectedPaymentMethod {
        case "apple": return "applelogo"
        case "blik": return "qrcode"
        case "sber": return "rublesign.circle.fill"
        default: return "creditcard.fill"
        }
    }
    
    func processPayment() {
        isProcessing = true
        
        // Symulacja przetwarzania płatności
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isProcessing = false
            cart.clearCart()
            showingSuccess = true
        }
    }
}

// Ekran sukcesu płatności
struct PaymentSuccessView: View {
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) private var dismiss
    
    let prepareAtTime: Bool
    let selectedTime: Date
    
    private var timeMessage: String {
        if prepareAtTime {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Twoja kawa będzie gotowa o \(formatter.string(from: selectedTime))"
        } else {
            return "Twoja kawa będzie gotowa do odbioru za 3 minuty"
        }
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 16) {
                Text("Płatność udana!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Twoje zamówienie zostało przyjęte")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Informacja o czasie przygotowania
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: prepareAtTime ? "clock.fill" : "timer")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                        
                        Text(timeMessage)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.blue.opacity(0.08))
                    )
                }
            }
            
            Spacer()
            
            Button(action: {
                dismiss()
                navigationPath = NavigationPath()
            }) {
                Text("Powrót do menu")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.white.ignoresSafeArea())
        .interactiveDismissDisabled()
    }
}
