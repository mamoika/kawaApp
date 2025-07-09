import SwiftUI

enum AppRoute: Hashable {
    case cart
    case orderDetail(Coffee)
    case payment(prepareAtTime: Bool, selectedTime: Date)
}
