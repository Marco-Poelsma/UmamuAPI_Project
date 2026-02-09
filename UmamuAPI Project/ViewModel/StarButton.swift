import SwiftUI

struct StarButton: View {

    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "star.fill" : "star")
                .foregroundColor(isOn ? .yellow : .gray)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
