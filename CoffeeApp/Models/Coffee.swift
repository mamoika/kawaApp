import Foundation

struct Coffee: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let image: String
    let price: Double
}
