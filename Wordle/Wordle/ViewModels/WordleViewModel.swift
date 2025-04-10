import Foundation
import SwiftUI

enum LetterStatus {
    case empty
    case wrong
    case misplaced
    case again
    case correct
}

enum WordleLanguage: String, CaseIterable {
    case czech = "Čeština"
    case english = "English"
    
    var fileName: String {
        switch self {
        case .czech:
            return "words_cs"
        case .english:
            return "words_en"
        }
    }
    
    var keyboardLetters: String {
        switch self {
        case .czech:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZÁČĎÉĚÍŇÓŘŠŤÚŮÝŽ"
        case .english:
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
    }
}

@MainActor
class WordleViewModel: ObservableObject {
    
    // MARK: -Structs
    struct WordEntry: Codable {
        var word: String
        var guessed: Bool
    }
    
    struct Letter {
        var letter: String
        var status: LetterStatus
    }
    
    @Published var board: [[Letter]]
    @Published var currentRow: Int
    @Published var currentCol: Int
    @Published var gameStatusMessage = " "
    @Published var isGameOver: Bool
    @Published var keyboardLetters: [String: LetterStatus]
    @Published var winned: Bool
    @Published var celebrated: Bool
    
    @Published var targetWord: String
    @Published var guessedWordsCount: Int
    @Published var totalWordsCount: Int = 0
    @Published var selectedLanguage: WordleLanguage = .czech
    
    private var words: [WordEntry] = []
    
    // MARK: -Init
    init() {
        self.board = Array(repeating: Array(repeating: Letter(letter: "", status: .empty), count: 5), count: 6)
        self.currentRow = 0
        self.currentCol = 0
        self.isGameOver = false
        self.winned = false
        self.celebrated = false
        self.keyboardLetters = [:]
        self.targetWord = "XXXXX"
        
        self.guessedWordsCount = 0
        
        // Load saved language preference if available
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = WordleLanguage.allCases.first(where: { $0.rawValue == savedLanguage }) {
            self.selectedLanguage = language
        }
        
        selectedLanguage.keyboardLetters.forEach { char in
            keyboardLetters[String(char)] = .empty
        }
        loadWordsFromJSON()
        
        self.targetWord = getRandomWord()
    }
    
    // MARK: -JSON
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func loadWordsFromJSON() {
        let savedFileName = "saved_words_\(selectedLanguage == .czech ? "cs" : "en")"
        let fileURL = getDocumentsDirectory().appendingPathComponent("\(savedFileName).json")
        
        if FileManager.default.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([WordEntry].self, from: data) {
            self.words = decoded
        } else if let bundledPath = Bundle.main.path(forResource: selectedLanguage.fileName, ofType: "json"),
                  let bundledData = try? Data(contentsOf: URL(fileURLWithPath: bundledPath)),
                  let decoded = try? JSONDecoder().decode([WordEntry].self, from: bundledData) {
            self.words = decoded
        }
        
        self.guessedWordsCount = words.filter { $0.guessed }.count
        self.totalWordsCount = words.count
    }
    
    func changeLanguage(to language: WordleLanguage) {
        guard language != selectedLanguage else { return }
        
        selectedLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "selectedLanguage")
        
        // Reset keyboard
        keyboardLetters.removeAll()
        selectedLanguage.keyboardLetters.forEach { char in
            keyboardLetters[String(char)] = .empty
        }
        
        // Load words for the new language
        loadWordsFromJSON()
        startNewGame()
    }

    // MARK: -Game
    private func getRandomWord() -> String {
        let unguessedWords = words.filter { !$0.guessed }
        return unguessedWords.randomElement()?.word.uppercased() ?? "AHOJ"
    }
    
    func addLetter(_ letter: String) {
        guard !isGameOver && currentCol < 5 else { return }
        
        board[currentRow][currentCol].letter = letter
        currentCol += 1
    }
    
    func removeLetter() {
        guard !isGameOver && currentCol > 0 else { return }
        
        currentCol -= 1
        board[currentRow][currentCol].letter = ""
        gameStatusMessage = " "
    }
    
    func submitGuess() {
        guard currentCol == 5 else { return }
        
        let guess = getCurrentWord()

        // ⛔️ Check if it's a valid word
        guard words.contains(where: { $0.word.uppercased() == guess }) else {
            gameStatusMessage = "Slovo není ve slovníku!"
            return
        }
        
        var targetLetterPositions: [Character: [Int]] = [:]
        var guessLetterCounts: [Character: Int] = [:]
        
        // Create a map of target word letter positions and count occurrences
        for (index, char) in targetWord.enumerated() {
            targetLetterPositions[char, default: []].append(index)
        }
        
        // Count occurrences of each letter in the guess
        for char in guess {
            guessLetterCounts[char, default: 0] += 1
        }
        
        // First pass: mark correct letters
        for i in 0..<5 {
            let guessLetter = guess[guess.index(guess.startIndex, offsetBy: i)]
            let targetLetter = targetWord[targetWord.index(targetWord.startIndex, offsetBy: i)]
            
            if guessLetter == targetLetter {
                board[currentRow][i].status = .correct
                targetLetterPositions[guessLetter]?.removeAll { $0 == i }
                guessLetterCounts[guessLetter]? -= 1
            }
        }
        
        // Second pass: mark misplaced and again letters
        for i in 0..<5 {
            let guessLetter = guess[guess.index(guess.startIndex, offsetBy: i)]
            
            if board[currentRow][i].status != .correct {
                if let positions = targetLetterPositions[guessLetter], !positions.isEmpty {
                    if guessLetterCounts[guessLetter] ?? 0 > 0 {
                        board[currentRow][i].status = .misplaced
                        targetLetterPositions[guessLetter]?.removeFirst()
                        guessLetterCounts[guessLetter]? -= 1
                    } else {
                        board[currentRow][i].status = .again
                    }
                } else {
                    board[currentRow][i].status = .wrong
                }
            }
        }
        
        // Update keyboard colors
        for i in 0..<5 {
            let guessLetter = guess[guess.index(guess.startIndex, offsetBy: i)]
            let currentStatus = board[currentRow][i].status
            
            // Count how many times this letter appears in the target word
            let targetCount = targetWord.filter { $0 == guessLetter }.count
            // Count how many times this letter is correctly placed in the current row
            let correctCount = (0..<5).filter { j in
                let letter = guess[guess.index(guess.startIndex, offsetBy: j)]
                return letter == guessLetter && board[currentRow][j].status == .correct
            }.count
            
            if currentStatus == .correct {
                // Only mark as correct if all instances are correctly placed
                if correctCount == targetCount {
                    keyboardLetters[String(guessLetter)] = .correct
                } else {
                    keyboardLetters[String(guessLetter)] = .misplaced
                }
            } else if currentStatus == .misplaced {
                if keyboardLetters[String(guessLetter)] != .correct {
                    keyboardLetters[String(guessLetter)] = .misplaced
                }
            } else if currentStatus == .again {
                keyboardLetters[String(guessLetter)] = .again
            } else if currentStatus == .wrong {
                if keyboardLetters[String(guessLetter)] != .correct && keyboardLetters[String(guessLetter)] != .misplaced {
                    keyboardLetters[String(guessLetter)] = .wrong
                }
            }
        }
        
        if guess == targetWord {
            winned = true
            gameStatusMessage = "Congratulations! 🎉"
            isGameOver = true
            
            // Mark the word as guessed
            if let index = words.firstIndex(where: { $0.word.uppercased() == targetWord }) {
                words[index].guessed = true
            }
            return
        }
        
        currentRow += 1
        currentCol = 0
        
        if currentRow >= 6 {
            gameStatusMessage = "The word was: \(targetWord)"
            isGameOver = true
        }
    }
    
    func startNewGame() {
        board = Array(repeating: Array(repeating: Letter(letter: "", status: .empty), count: 5), count: 6)
        currentRow = 0
        currentCol = 0
        isGameOver = false
        winned = false
        celebrated = false
        gameStatusMessage = " "
        
        targetWord = getRandomWord()
        
        keyboardLetters.keys.forEach { key in
            keyboardLetters[key] = .empty
        }
    }
    
    func resetAllWords() {
        // Reset all words to unguessed
        for i in 0..<words.count {
            words[i].guessed = false
        }
        startNewGame()
    }
    
    private func getCurrentWord() -> String {
        return board[currentRow].map { $0.letter }.joined()
    }
    
    // MARK: -Counting
    func countGuessedWords() {
        guessedWordsCount = words.filter { $0.guessed }.count
    }
}
