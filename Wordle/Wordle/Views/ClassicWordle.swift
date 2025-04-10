//
//  ClassicWordle.swift
//  Wordle
//
//  Created by Kryštof Sláma on 05.04.2025.
//
import SwiftUI
import ConfettiSwiftUI
import Foundation

struct ClassicWordle: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: WordleViewModel
    
    @State private var trigger: Int = 0
    
    var body: some View {
        VStack {
            // Game board
            VStack(spacing: 5) {
                ForEach(0..<6) { row in
                    HStack(spacing: 5) {
                        ForEach(0..<5) { col in
                            LetterCell(letter: viewModel.board[row][col].letter,
                                       status: viewModel.board[row][col].status)
                        }
                    }
                }
            }
            .padding(.horizontal, 50)
            // Game Status, new game button
            HStack {
                if viewModel.winned && !viewModel.celebrated {
                    Text("")
                        .onAppear {
                            trigger += 1
                            viewModel.celebrated = true
                        }
                }
                Text(viewModel.gameStatusMessage)
                    .font(.headline)
                    .foregroundColor(viewModel.isGameOver ? .green : .red)
                    .confettiCannon(trigger: $trigger, num: 100, rainHeight: 600, fadesOut: true, openingAngle: Angle.degrees(70), closingAngle: Angle.degrees(105), radius: 550, hapticFeedback: true)
                
                if viewModel.isGameOver {
                    Button("New Game") {
                        viewModel.startNewGame()
                    }
                    .fontWeight(.heavy)
                    .buttonStyle(.plain)
                }
            }.padding(.vertical)
            
            // Keyboard
            KeyboardView(viewModel: viewModel)
            
            Spacer()
        }
        .navigationTitle("WORDLE")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .light ? Color(red: 250/255, green: 240/255, blue: 230/255) : Color.black)
    }
}

struct LetterCell: View {
    let letter: String
    let status: LetterStatus
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .aspectRatio(0.9, contentMode: .fit)
                .cornerRadius(8)
            
            Text(letter)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    private var backgroundColor: Color {
        switch status {
        case .empty:
            return Color(.systemGray4)
        case .wrong:
            return .gray
        case .misplaced, .again:
            return .yellow
        case .correct:
            return .green
        }
    }
}

struct ClassicWordle_Previews: PreviewProvider {
    static var previews: some View {
        ClassicWordle(viewModel: WordleViewModel())
            .environmentObject(SettingsManager())
    }
}

