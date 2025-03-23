//
//  SettingsView.swift
//  watermarkremover
//
//  Created by Julian Beck on 23.03.25.
//


import SwiftUI
import RevenueCat

struct SettingsView: View {
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.accentColor.opacity(0.3),
                        Color.accentColor.opacity(0.5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                HStack {
                    Spacer(minLength: 0)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Settings")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                if globalViewModel.isPro {
                                    HStack {
                                        Image(systemName: "crown.fill")
                                            .foregroundColor(.yellow)
                                        Text("Pro Member")
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        List {
                            Section {
                                if !globalViewModel.isPro {
                                    SettingsRow(
                                        icon: "star.fill",
                                        iconColor: .red,
                                        title: "Upgrade to Pro",
                                        subtitle: "Unlimited try-ons"
                                    ) {
                                        globalViewModel.isShowingPayWall.toggle()
                                    }
                                }
                                
                                SettingsRow(
                                    icon: "star.fill",
                                    iconColor: .yellow,
                                    title: "Rate TryOn",
                                    subtitle: "Leave a review on the App Store"
                                ) {
                                    globalViewModel.isShowingRatings = true
                                }
                            } header: {
                                Text("Support & Info")
                                    .textCase(nil)
                                    .font(.title2)
                                    .bold()
                            }
                            
                            Section {
                                SettingsRow(
                                    icon: "repeat.circle.fill",
                                    iconColor: .green,
                                    title: "Show Onboarding",
                                    subtitle: "See the app intro again"
                                ) {
                                    globalViewModel.isShowingOnboarding = true
                                }
                                
                                SettingsRow(
                                    icon: "arrow.clockwise.circle.fill",
                                    iconColor: .blue,
                                    title: "Restore Purchases",
                                    subtitle: "Recover your Pro subscription"
                                ) {
                                    globalViewModel.restorePurchase()
                                }
                            } header: {
                                Text("App Settings")
                                    .textCase(nil)
                                    .font(.title2)
                                    .bold()
                            }
                            
                            Section {
                                SettingsRow(
                                    icon: "hand.raised.fill",
                                    iconColor: .indigo,
                                    title: "Privacy Policy",
                                    subtitle: "How we handle your data"
                                ) {
                                    UIApplication.shared.open(Helpers.privacyPolicyURL)
                                }
                                
                                SettingsRow(
                                    icon: "doc.text.fill",
                                    iconColor: .orange,
                                    title: "Terms of Service",
                                    subtitle: "Usage terms and conditions"
                                ) {
                                    UIApplication.shared.open(Helpers.termsOfServiceURL)
                                }
                                
                                SettingsRow(
                                    icon: "questionmark.circle.fill",
                                    iconColor: .teal,
                                    title: "Support",
                                    subtitle: "Get help with TryOn"
                                ) {
                                    UIApplication.shared.open(Helpers.supportURL)
                                }
                            } header: {
                                Text("Legal")
                                    .textCase(nil)
                                    .font(.title2)
                                    .bold()
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                    .frame(maxWidth: 650)
                    Spacer(minLength: 0)
                }
            }
            .navigationTitle("Settings")
            .navigationBarHidden(true)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let onClick: () -> Void
    
    var body: some View {
        Button {
            onClick()
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)
                    .background(iconColor.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fontWeight(.bold)
                }
                Spacer()
            }
            .padding(.vertical, 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .environmentObject(GlobalViewModel())
} 
