//
//  WordleApp.swift
//  Wordle
//
//  Created by Kryštof Sláma on 05.04.2025.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct WordleApp: App {
    @StateObject var settings = SettingsManager()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .preferredColorScheme(
                    settings.selectedTheme == .system ? nil :
                    settings.selectedTheme == .dark ? .dark : .light
                )
        }
    }
}
