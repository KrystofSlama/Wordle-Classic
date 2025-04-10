//
//  SettingsManager.swift
//  Wordle
//
//  Created by Kryštof Sláma on 07.04.2025.
//

import Swift
import SwiftUI
import Foundation

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case light, dark, system
    var id: String { self.rawValue }
}

class SettingsManager: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: AppTheme = .system
    @AppStorage("soundEnabled") var soundEnabled: Bool = false
}
