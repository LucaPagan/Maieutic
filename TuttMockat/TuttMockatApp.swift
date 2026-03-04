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
    @StateObject private var session = GuestSessionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
        .modelContainer(for: [AppUser.self, InteractionMetric.self, ChatThread.self])
    }
}
