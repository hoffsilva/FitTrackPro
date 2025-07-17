//
//  FitTrackProApp.swift
//  FitTrackPro
//
//  Created by Hoff Henry Pereira da Silva on 2025-07-13.
//

import SwiftUI
import Resolver

@main
struct FitTrackProApp: App {
    
    init() {
        // Configure dependency injection
        Resolver.registerAllServices()
        
        // Add development data for testing
        #if DEBUG
        Resolver.addDevelopmentData()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
