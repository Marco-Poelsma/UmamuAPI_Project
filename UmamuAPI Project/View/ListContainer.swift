// TransparentList.swift
import SwiftUI

struct TransparentList<Content: View>: UIViewRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIView(context: Context) -> UITableView {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.backgroundView = UIView()
        table.separatorStyle = .none
        return table
    }

    func updateUIView(_ uiView: UITableView, context: Context) {
        // no-op
    }
}
