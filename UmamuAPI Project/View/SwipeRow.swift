import SwiftUI

struct SwipeRow<Content: View>: View {
    let id: Int
    let onDelete: (Int) -> Void
    let content: Content

    @State private var offsetX: CGFloat = 0
    @State private var isDragging = false

    private let threshold: CGFloat = -80

    init(id: Int, onDelete: @escaping (Int) -> Void, @ViewBuilder content: () -> Content) {
        self.id = id
        self.onDelete = onDelete
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            if isDragging || offsetX < 0 {
                Color.red
                    .cornerRadius(20)
                    .overlay(
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .padding(.trailing, 30),
                        alignment: .trailing
                    )
            }

            content
                .offset(x: offsetX)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            if value.translation.width < 0 {
                                offsetX = value.translation.width
                            }
                        }
                        .onEnded { value in
                            isDragging = false
                            if value.translation.width < threshold {
                                onDelete(id)
                            } else {
                                offsetX = 0
                            }
                        }
                )
                .animation(.spring(), value: offsetX)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
    }
}
