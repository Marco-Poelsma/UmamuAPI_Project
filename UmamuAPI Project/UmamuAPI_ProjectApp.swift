//
//  UmamuAPI_ProjectApp.swift
//  UmamuAPI Project
//
//  Created by alumne on 19/01/2026.
//

import SwiftUI

@main
struct UmamuAPI_ProjectApp: App {
    init() {
        // Cargar datos en caché al iniciar la app
        DataCache.shared.loadInitialDataIfNeeded()
        
        // Configurar apariencia global
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(.appBlue)
        }
    }
}
