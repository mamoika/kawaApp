import SwiftUI

struct ContentView: View {
    @State private var selectedCafe: CafeAddress? = nil
    @StateObject var cart = CartViewModel()

    var body: some View {
        ZStack {
            if let cafe = selectedCafe {
                MenuView(selectedCafe: cafe)
                    .environmentObject(cart)
                    .transition(.move(edge: .trailing)) // animacja przesunięcia
            } else {
                CafeSelectionView { chosenCafe in
                    withAnimation(.easeInOut) {
                        selectedCafe = chosenCafe
                    }
                }
                .transition(.move(edge: .leading)) // animacja przesunięcia
            }
        }
        .animation(.easeInOut, value: selectedCafe)
    }
}
