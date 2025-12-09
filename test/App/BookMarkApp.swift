//
//  testApp.swift
//  test
//
//  Created by dsu_student on 11/18/25.
//

import SwiftUI

@main
struct BookMarkApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
