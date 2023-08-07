//
//  QuictionaryApp.swift
//  Quictionary
//
//  Created by Marco Vasquez on 2/3/23.
//  Main application

import SwiftUI

@main
struct QuictionaryApp: App {
    // Persistence controller
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        let dictionaryModel = DictionaryModel(context: persistenceController.container.viewContext)
        let dictionaryController = DictionaryController(model: dictionaryModel)
        
        WindowGroup {
            TabBarView()
                .environmentObject(dictionaryController)
        }
    }
}
