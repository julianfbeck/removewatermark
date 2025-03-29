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
                WaterMarkRemovalView()
                    .fullScreenCover(isPresented: $globalViewModel.isShowingPayWall) {
                        PayWallView()
                            
                    }
            }
        }
    }
}
