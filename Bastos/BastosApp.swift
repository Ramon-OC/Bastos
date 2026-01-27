//
//  BastosApp.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 09/01/26.
//

import SwiftUI
import CoreData

@main
struct BastosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MediaDeckView()
                .environment(\.managedObjectContext,
                             persistenceController.container.viewContext)
        }
    }
}
