import Foundation

struct CoffeeOrder: Identifiable {
    let id = UUID()
    let nazwaKawy: String // Nowe pole przechowujące konkretną nazwę kawy (np. "Cappuccino")
    let image: String
    let price: Double
    let rodzajKawy: String
    let stopienPalenia: Int
    let mielenie: Int
    let mleko: String
    let syrop: String
    let dodatki: [String]
    let iloscLodu: Int
    let miejsce: String? // "Na miejscu" lub "Na wynos"
    let objetosc: Int? // 250, 350, 450
    let prepareAtTime: Bool      // Dodaj
    let selectedTime: Date 
}
