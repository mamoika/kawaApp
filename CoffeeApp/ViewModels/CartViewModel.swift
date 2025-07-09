import SwiftUI

class CartViewModel: ObservableObject {
    @Published var items: [CoffeeOrder] = []
    
    func addOrder(_ order: CoffeeOrder) {
        items.append(order)
    }
    
    func removeOrder(_ order: CoffeeOrder) {
        items.removeAll { $0.id == order.id }
    }
    func clearCart() {
        items.removeAll()
    }

}
