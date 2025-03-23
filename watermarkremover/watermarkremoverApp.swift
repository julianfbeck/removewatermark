//
//  watermarkremoverApp.swift
//  watermarkremover
//
//  Created by Julian Beck on 21.03.25.
//

import SwiftUI
import RevenueCat

@main
struct watermarkremoverApp: App {
    @StateObject var globalViewModel = GlobalViewModel()
    @StateObject var wmrm = WaterMarkRemovalModel()
    
    init() {
        Purchases.configure(withAPIKey: "appl_KIgdiugXJfhqQJjnhXZnVapWakD")
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(globalViewModel)
                .environmentObject(wmrm)
                .onAppear {
                    Plausible.shared.configure(domain: "tryon.juli.sh", endpoint: "https://stats.juli.sh/api/event")
                }
        }
    }
}
