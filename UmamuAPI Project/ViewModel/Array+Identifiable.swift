import Foundation

extension Array {
    func isFirst(_ element: Element) -> Bool where Element: Identifiable {
        first?.id == element.id
    }

    func isLast(_ element: Element) -> Bool where Element: Identifiable {
        last?.id == element.id
    }
}
