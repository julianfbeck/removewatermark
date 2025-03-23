//
//  MainTabView.swift
//  watermarkremover
//
//  Created by Julian Beck on 23.03.25.
//
import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        TabView {
            WaterMarkRemovalView()
                .tabItem {
                    Label("Try On", systemImage: "tshirt.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.accentColor) // This uses the asset catalog's accent color
    }
}
