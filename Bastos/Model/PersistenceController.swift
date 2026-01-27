//
//  PersistenceController.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 27/01/26.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Model") // Cambia "Bastos" por el nombre de tu .xcdatamodeld

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error loading Core Data: \(error)")
            }
        }
    }
}
