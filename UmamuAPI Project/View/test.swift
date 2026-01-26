//
//  test.swift
//  UmamuAPI Project
//
//  Created by alumne on 26/01/2026.
//

import SwiftUI

struct test: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(1...100, id: \.self) {
                    Text("Row \($0)")
                }
            }
        }
    }
}
