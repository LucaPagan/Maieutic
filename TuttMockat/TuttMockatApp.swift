//
//  TuttMockatApp.swift
//  TuttMockat
//
//  Created by Luca Pagano on 1/28/26.
//

import SwiftUI
import SwiftData

@main
struct TuttMockatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [AppUser.self, InteractionMetric.self, ChatThread.self])
    }
}
