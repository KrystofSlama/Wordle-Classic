//
//  ContentView.swift
//  Wordle
//
//  Created by Kryštof Sláma on 05.04.2025.
//

import SwiftUI
import Foundation

@MainActor
struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @StateObject private var viewModel = WordleViewModel()
    @EnvironmentObject private var settings: SettingsManager
    
    var body: some View {
        NavigationStack {
            VStack {
                    Text("WORDLE")
                        .font(.system(size: 70, weight: .bold))
                        .padding(.top)
                
                Spacer()
                VStack(spacing: 20) {
                    NavigationLink {
                        ClassicWordle(viewModel: viewModel)
                    } label: {
                        Text("Play")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                    }
                    
                    NavigationLink {
                        OptionsView(viewModel: viewModel)
                    } label: {
                        Text("Options")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                    }
                }
                Spacer()
                
                Text(" ")
                    .font(.system(size: 70, weight: .bold))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme == .light ? Color(red: 250/255, green: 240/255, blue: 230/255) : Color.black)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SettingsManager())
}
