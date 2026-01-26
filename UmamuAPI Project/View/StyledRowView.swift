import SwiftUI

struct StyledRowView: View {

    let title: String
    let id: Int          // <- Nuevo parámetro

    var isFavorite: Bool = false
    var showsFavorite: Bool = false

    var accessory: RowAccessory = .none
    var onAccessoryTap: (() -> Void)? = nil
    var onFavoriteTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {

            Text("\(id)")
                .font(.headline)
                .lineLimit(1)
                .fixedSize()
            
            Text(title)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)

            

            Spacer()

            if showsFavorite {
                Button(action: {
                    onFavoriteTap?()
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.system(size: 16))
                        .foregroundColor(isFavorite ? .yellow : .gray)
                }
                .buttonStyle(PlainButtonStyle())
            }

            accessoryView()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func accessoryView() -> some View {
        switch accessory {
        case .none:
            EmptyView()

        case .select:
            Button(action: {
                onAccessoryTap?()
            }) {
                Text("Select")
                    .font(.subheadline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }

        case .details:
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)

        case .detailsWithFavorite:
            HStack(spacing: 6) {
                Text("Details")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }

    enum RowAccessory {
        case none
        case select
        case details
        case detailsWithFavorite
    }
}
