import SwiftUI

struct ScrollableListContainer<Content: View>: View {

    let radius: CGFloat
    let content: () -> Content

    init(
        radius: CGFloat,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.radius = radius
        self.content = content
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                content()
            }
            .background(Color(UIColor.secondarySystemFill))
            .cornerRadius(radius)
            .padding(.horizontal, 8)
            .padding(.top, 8)
        }
    }
}
