//
//  OptionsView.swift
//  Wordle
//
//  Created by Kryštof Sláma on 07.04.2025.
//

import SwiftUI
import Foundation

@MainActor
struct OptionsView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject var settings: SettingsManager
    @ObservedObject var viewModel: WordleViewModel
    @StateObject private var fireViewModel = FireStoreViewModel()
    
    @State private var showUpdateSheet: Bool = false
    @State private var showSuggestionSheet: Bool = false
    @State private var showReportSheet: Bool = false
    @State private var showReportBugSheet: Bool = false
    @State private var showHelpSheet: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Language selector
            VStack(spacing: 10) {
                Spacer()
                List {
                    // MARK: -Words
                    Section("Words") {
                        HStack {
                            Menu {
                                ForEach(WordleLanguage.allCases, id: \.self) { language in
                                    Button(action: {
                                        viewModel.changeLanguage(to: language)
                                    }) {
                                        HStack {
                                            Text(language.rawValue)
                                            if viewModel.selectedLanguage == language {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("Language")
                                        .font(.title3)
                                        .foregroundStyle(colorScheme == .light ? Color.black : Color.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .resizable()
                                        .frame(width: 13, height: 8)
                                        .foregroundStyle(colorScheme == .light ? Color.black : Color.white)
                                }
                            }
                        }
                        
                        NavigationLink {
                            
                        } label: {
                            Text("Statistics (Coming Soon)")
                                .font(.title3)
                                .foregroundStyle(colorScheme == .light ? Color.black : Color.white)
                        }.disabled(true)
                        
                        Button {
                            showSuggestionSheet = true
                        } label: {
                            Text("Suggest New Word")
                        }
                        .sheet(isPresented: $showSuggestionSheet) {
                            SuggestWordView()
                        }
                        
                        Button {
                            showReportSheet = true
                        } label: {
                            Text("Report Bad Word")
                        }
                        .sheet(isPresented: $showReportSheet) {
                            ReportWordView()
                        }
                    }
                    
                    // MARK: -Settings
                    Section("Settings") {
                        Picker("Theme", selection: $settings.selectedTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(label(for: theme)).tag(theme)
                            }
                        }
                        .pickerStyle(.automatic)
                        
                        Toggle("Sound (Coming Soon)", isOn: $settings.soundEnabled)
                            .disabled(true)
                        
                        Button {
                            showReportBugSheet = true
                        } label: {
                            Text("Report Bug")
                        }
                        .sheet(isPresented: $showReportBugSheet) {
                            ReportBugView()
                        }
                    }
                    
                    // MARK: -Last section
                    Section {
                        Button {
                            showUpdateSheet = true
                        } label: {
                            Text("What's new")
                        }
                        .sheet(isPresented: $showUpdateSheet) {
                            UpdateLogView()
                        }
                        
                        Button {
                            showHelpSheet = true
                        } label: {
                            Text("Want to Help?")
                        }
                        .sheet(isPresented: $showHelpSheet) {
                            HelpView()
                        }
                    }
                }.scrollContentBackground(.hidden)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Options")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme == .light ? Color(red: 250/255, green: 240/255, blue: 230/255) : Color.black)
        }
    }
    func label(for theme: AppTheme) -> String {
        switch theme {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
}

// MARK: -Sheets
struct SuggestWordView: View {
    @ObservedObject var fireViewModel = FireStoreViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var word = ""
    @State private var language = "en"
    @State private var showThanks = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Word")) {
                    TextField("Your word", text: $word)
                        .textInputAutocapitalization(.never)
                }

                Section(header: Text("Language")) {
                    Menu {
                        Button("🇬🇧 Angličtina") { language = "en" }
                        Button("🇨🇿 Čeština") { language = "cs" }
                    } label: {
                        
                        HStack {
                            Text(languageLabel(for: language))
                                .foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                    }
                }

                Button("📤 Send for suggestion") {
                    guard word.count == 5 else { return }
                    fireViewModel.suggestWord(word: word, language: language)
                    word = ""
                    showThanks = true
                }
                .disabled(word.count != 5)
            }
            .navigationTitle("Suggest a word")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zavřít") {
                        dismiss()
                    }
                }
            }
            .alert("Thank you!", isPresented: $showThanks) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("Word was sent for approval.")
            }
        }
    }
    
    func languageLabel(for code: String) -> String {
        switch code {
        case "cs": return "🇨🇿 Čeština"
        case "en": return "🇬🇧 Angličtina"
        default: return "🌐 \(code)"
        }
    }
}

struct ReportWordView: View {
    @ObservedObject var fireViewModel = FireStoreViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var word = ""
    @State private var language = "en"
    @State private var showThanks = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Word")) {
                    TextField("Word for report", text: $word)
                        .textInputAutocapitalization(.never)
                }

                Section(header: Text("Language")) {
                    Menu {
                        Button("🇬🇧 Angličtina") { language = "en" }
                        Button("🇨🇿 Čeština") { language = "cs" }
                    } label: {
                        
                        HStack {
                            Text(languageLabel(for: language))
                                .foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                    }
                }

                Button("📤 Send for report") {
                    guard word.count == 5 else { return }
                    fireViewModel.reportWord(word: word, language: language)
                    word = ""
                    showThanks = true
                }
                .disabled(word.count != 5)
            }
            .navigationTitle("Report a word")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Thank you!", isPresented: $showThanks) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("Word was sent for checking.")
            }
        }
    }
    
    func languageLabel(for code: String) -> String {
        switch code {
        case "cs": return "🇨🇿 Čeština"
        case "en": return "🇬🇧 Angličtina"
        default: return "🌐 \(code)"
        }
    }
}

struct ReportBugView: View {
    @ObservedObject var fireViewModel = FireStoreViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var word = ""
    @State private var language = "en"
    @State private var showThanks = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Report")) {
                    TextEditor(text: $word)
                        .frame(minHeight: 80)
                        .padding(.horizontal, -4)
                }

                Button("📤 Send report") {
                    guard word.count >= 5 else { return }
                    fireViewModel.reportBug(word: word, language: "Bug")
                    word = ""
                    showThanks = true
                }
            }
            .navigationTitle("Report a Bug")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Thank you!", isPresented: $showThanks) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("We will look into it.")
            }
        }
    }
}

struct HelpView: View {
    @ObservedObject var fireViewModel = FireStoreViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var name = ""
    @State private var expirience = ""
    @State private var language = "en"
    @State private var showThanks = false
    
    var body: some View {
        NavigationView {
            Form {
                Text("We are always looking for someone to help. You would be great help if you are experineced developer or just want to build our word database.")
                
                Section(header: Text("Leave your contact information")) {
                    TextField("Your Email", text: $email)
                    TextField("Name", text: $name)
                    TextField("Experience", text: $expirience)
                }

                Button("📤 Send contact information") {
                    guard email.count >= 5 || name.isEmpty || expirience.isEmpty else { return }
                    fireViewModel.uploadHelpData(name: name, email: email, experience: expirience)
                    name = ""
                    email = ""
                    expirience = ""
                    showThanks = true
                }
            }
            .navigationTitle("Want to Help?")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Thank you!", isPresented: $showThanks) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("We will contact you as soon as possible.")
            }
        }
    }
}

struct UpdateLogView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("What's coming")) {
                    Text("🟡 More languages")
                    Text("🟡 iPad support")
                    Text("🟡 Statistics")
                    Text("🟡 More difficulties")
                    Text("🟡 More game modes")
                    Text("🟡 Sounds")
                }

                Section(header: Text("Version 1.0.0")) {
                    Text("✅ Czech language")
                    Text("✅ Reporting words")
                    Text("✅ Adding words")
                    Text("✅ Classic mode")
                    Text("✅ Light / Dark mode")
                }
            }
            .navigationTitle("New features")
        }
    }
}

#Preview {
    OptionsView(viewModel: WordleViewModel())
        .environmentObject(SettingsManager())
}
