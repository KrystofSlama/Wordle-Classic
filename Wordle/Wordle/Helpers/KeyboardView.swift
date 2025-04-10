import SwiftUI

struct KeyboardView: View {
    @ObservedObject var viewModel: WordleViewModel
    
    private let rows_cs = [
        ["Ě", "Š", "Č", "Ř", "Ž", "Ý", "Á", "Í", "É"],
        ["Q", "W", "E", "R", "T", "Z", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["ENTER", "Y", "X", "C", "V", "B", "N", "M", "⌫"]
    ]
    
    private let rows_en = [
        ["Q", "W", "E", "R", "T", "Z", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["ENTER", "Y", "X", "C", "V", "B", "N", "M", "⌫"]
    ]
    
    private var currentRows: [[String]] {
        switch viewModel.selectedLanguage {
        case .czech:
            return rows_cs
        case .english:
            return rows_en
        }
    }
    
    var body: some View {
        VStack(spacing: 3) {
            ForEach(currentRows, id: \.self) { row in
                HStack(spacing: 3) {
                    ForEach(row, id: \.self) { key in
                        KeyboardButton(key: key, viewModel: viewModel)
                    }
                }
            }
        }
    }
}

struct KeyboardButton: View {
    let key: String
    @ObservedObject var viewModel: WordleViewModel
    
    var body: some View {
        Button(action: {
            switch key {
            case "⌫":
                viewModel.removeLetter()
            case "ENTER":
                viewModel.submitGuess()
            default:
                viewModel.addLetter(key)
            }
        }) {
            Text(key)
                .font(fontForKey)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: buttonWidth, height: 45)
                .background(backgroundColor)
                .cornerRadius(5)
        }
    }
    
    private var fontForKey: Font {
        switch key {
        case "ENTER":
            return .system(size: 16)
        case "⌫":
            return .largeTitle
        default:
            return .title2
        }
    }
    
    private var buttonWidth: CGFloat {
        switch key {
        case "ENTER":
            return 60
        case "⌫":
            return 60
        default:
            return 33
        }
    }
    
    private var backgroundColor: Color {
        if key == "ENTER" || key == "⌫" {
            return .gray
        }
        
        switch viewModel.keyboardLetters[key] {
        case .correct:
            return .green
        case .misplaced, .again:
            return .yellow
        case .wrong:
            return .gray
        case .empty:
            return .gray.opacity(0.3)
        case .none:
            return .gray.opacity(0.3)
        }
    }
} 
