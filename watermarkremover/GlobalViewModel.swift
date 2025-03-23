//
//  GlobalViewModel.swift
//  watermarkremover
//
//  Created by Julian Beck on 23.03.25.
//

import Foundation
import RevenueCat

class GlobalViewModel: ObservableObject {
    @Published var offering: Offering?
    @Published var customerInfo: CustomerInfo?
    @Published var isPurchasing = false
    @Published var errorMessage: String?
    @Published var isShowingPayWall = false
    @Published var isShowingOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(!isShowingOnboarding, forKey: "hasSeenOnboarding")
        }
    }
    @Published var isShowingRatings = false
    @Published var remainingUses: Int
    @Published var canUseForFree: Bool
    @Published var downloadCount: Int {
        didSet {
            UserDefaults.standard.set(downloadCount, forKey: "downloadCount")
        }
    }
  
    @Published var isPro: Bool {
        didSet {
            UserDefaults.standard.set(isPro, forKey: "isPro")
        }
    }
    
    @Published var dailyUsageLimit: Int {
        didSet {
            UserDefaults.standard.set(dailyUsageLimit, forKey: "dailyUsageLimit")
        }
    }
    @Published var dailyUsageCount: Int {
        didSet {
            UserDefaults.standard.set(dailyUsageCount, forKey: "dailyUsageCount")
        }
    }
    @Published var lastUsageDate: Date? {
        didSet {
            if let date = lastUsageDate {
                UserDefaults.standard.set(date, forKey: "lastUsageDate")
            }
        }
    }
    
    private let maxUsageCount: Int = 3
    private let featureKey = "finalUsageCountforReal"
    private let baseDailyLimit: Int = 2
    let maxDownlaods: Int = 3
    
    // Track if this is the first launch
    private var isFirstLaunch: Bool {
        return isShowingOnboarding
    }
    
    init() {
        // Initialize all properties first
        self.isPro = UserDefaults.standard.bool(forKey: "isPro")
        self.downloadCount = UserDefaults.standard.integer(forKey: "downloadCount")
        
        // Check if the user has seen the onboarding
        self.isShowingOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        let currentUsage = UserDefaults.standard.integer(forKey: featureKey)
        self.remainingUses = max(0, maxUsageCount - currentUsage)
        self.canUseForFree = currentUsage < maxUsageCount
        
        // Initialize usage tracking
        self.dailyUsageLimit = UserDefaults.standard.integer(forKey: "dailyUsageLimit")
        self.dailyUsageCount = UserDefaults.standard.integer(forKey: "dailyUsageCount")
        
        if let savedDate = UserDefaults.standard.object(forKey: "lastUsageDate") as? Date {
            self.lastUsageDate = savedDate
        } else {
            self.lastUsageDate = Date()
        }
        
        // Now that all properties are initialized, we can perform additional setup
        
        // Reset daily count if it's a new day
        if let savedDate = self.lastUsageDate, !Calendar.current.isDate(savedDate, inSameDayAs: Date()) {
            self.dailyUsageCount = 0
        }
        
        // Set initial daily limit if needed
        if self.dailyUsageLimit == 0 {
            self.dailyUsageLimit = baseDailyLimit
        }
        
        if self.isPro {
            self.canUseForFree = true
        }
        
        // If user is not pro and has already seen onboarding, show paywall
        if !self.isPro && !self.isShowingOnboarding {
            self.isShowingPayWall = true
        }
        
        setupPurchases()
        fetchOfferings()
    }
    
    private func setupPurchases() {
        self.isPro = UserDefaults.standard.bool(forKey: "isPro")
        Purchases.shared.getCustomerInfo { [weak self] (customerInfo, _) in
            DispatchQueue.main.async {
                let isProActive = customerInfo?.entitlements["PRO"]?.isActive == true
                UserDefaults.standard.set(isProActive, forKey: "isPro")
                self?.isPro = isProActive
            }
        }
    }
    
    private func fetchOfferings() {
        Purchases.shared.getOfferings { [weak self] (offerings, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if let defaultOffering = offerings?.offering(identifier: "default") {
                    self?.offering = defaultOffering
                }
            }
        }
    }
    
    func purchase(package: Package) {
        isPurchasing = true
        Purchases.shared.purchase(package: package) { [weak self] (_, customerInfo, _, userCancelled) in
            DispatchQueue.main.async {
                self?.isPurchasing = false
                if let isProActive = customerInfo?.entitlements["PRO"]?.isActive {
                    self?.updateProStatus(isProActive)
                }
            }
        }
    }
    
    func restorePurchase() {
        Purchases.shared.restorePurchases { [weak self] customerInfo, _ in
            let isProActive = customerInfo?.entitlements["PRO"]?.isActive == true
            self?.updateProStatus(isProActive)
        }
    }
    
    private func updateProStatus(_ isPro: Bool) {
        self.isPro = isPro
        UserDefaults.standard.set(isPro, forKey: "isPro")
        if isPro {
            self.isShowingPayWall = false
        }
    }
    
    func useFeature() -> Bool {
        if isPro {
            return true
        }
        
        // Check if it's a new day
        if let lastDate = lastUsageDate, !Calendar.current.isDate(lastDate, inSameDayAs: Date()) {
            dailyUsageCount = 0
            lastUsageDate = Date()
        } else if lastUsageDate == nil {
            lastUsageDate = Date()
        }
        
        // Check daily limit
        if dailyUsageCount >= dailyUsageLimit {
            isShowingPayWall = true
            return false
        }
        
        // Increment usage count
        dailyUsageCount += 1
        lastUsageDate = Date()
        
        // Legacy usage tracking
        let currentUsage = UserDefaults.standard.integer(forKey: featureKey)
        if currentUsage <= maxUsageCount {
            UserDefaults.standard.set(currentUsage + 1, forKey: featureKey)
            updateUsageStatus()
        }
        
        return true
    }
    
    func resetUsage() {
        UserDefaults.standard.set(0, forKey: featureKey)
        updateUsageStatus()
        dailyUsageCount = 0
    }
    
    private func updateUsageStatus() {
        let currentUsage = UserDefaults.standard.integer(forKey: featureKey)
        remainingUses = max(0, maxUsageCount - currentUsage)
        canUseForFree = currentUsage < maxUsageCount || isPro
    }
    
    func incrementDownloadCount() {
        downloadCount += 1
    }
    
    // Return remaining uses for today
    var remainingUsesToday: Int {
        return max(0, dailyUsageLimit - dailyUsageCount)
    }
}
