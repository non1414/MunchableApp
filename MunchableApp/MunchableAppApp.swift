//
//  MunchableAppApp.swift
//  MunchableApp
//
//  Created by نوف بخيت الغامدي on 10/03/1447 AH.
//
import SwiftUI

@main
struct MUNCHABLEApp: App {
    @StateObject private var api   = APIService()
    @StateObject private var store = IngredientsStore()

    var body: some Scene {
        WindowGroup {
            RootSwitchView()
                .environmentObject(api)
                .environmentObject(store)
                .task { api.login() }
        }
    }
}

struct RootSwitchView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                Make_it_()                         // ← شاشتك الرئيسية
            } else {
                Onboarding(onFinish: {
                    hasSeenOnboarding = true     
                })
            }
        }
    }
}
