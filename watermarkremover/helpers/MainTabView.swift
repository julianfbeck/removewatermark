//
//  MainTabView.swift
//  watermarkremover
//
//  Created by Julian Beck on 23.03.25.
//
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    var body: some View {
        Group {
            if globalViewModel.isShowingOnboarding {
                OnboardingView()
            } else {
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
            }
        }
    }
}
