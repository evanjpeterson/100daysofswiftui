//
//  ContentView.swift
//  WordScramble
//
//  Created by Evan Peterson on 10/15/24.
//

import SwiftUI

struct ContentView: View {
    @FocusState private var hasFocus: Bool

    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    func resetGame() {
        usedWords = []
        newWord = ""
        startGame()
    }

    func startGame() {
        if let wordsFileURL = Bundle.main.url(
            forResource: "words",
            withExtension: ".txt"
        ) {
            hasFocus = true
            if let wordsFile = try? String(contentsOf: wordsFileURL) {
                let allWords = wordsFile.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "scramble"
                return
            }
        }

        fatalError("Oops! We couldn't load the word bank.")
    }

    func wordIsOriginal(_ word: String) -> Bool {
        !usedWords.contains(word)
    }

    func wordIsPossible(_ word: String) -> Bool {
        var letterBank = rootWord
        for letter in word {
            if let i = letterBank.firstIndex(of: letter) {
                letterBank.remove(at: i)
            } else {
                return false
            }
        }
        return true
    }

    func wordIsReal(_ word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(
            in: word,
            range: range,
            startingAt: 0,
            wrap: false,
            language: "en"
        )
        return misspelledRange.location == NSNotFound
    }

    func wordIsNotRoot(_ word: String) -> Bool {
        return word != rootWord
    }

    func wordIsLongEnough(_ word: String) -> Bool {
        return word.count >= 3
    }

    func wordError(title: String, msg: String) {
        errorTitle = title
        errorMessage = msg
        showingError = true
    }

    func addNewWord() {
        let answer = newWord.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard answer.count > 0 else { return }
        guard wordIsOriginal(answer) else {
            wordError(
                title: "Try again!",
                msg: "You've already entered '\(newWord)'."
            )
            return
        }
        guard wordIsPossible(answer) else {
            wordError(
                title: "Try again!",
                msg: "You can't make '\(newWord)' using '\(rootWord)'."
            )
            return
        }
        guard wordIsReal(answer) else {
            wordError(
                title: "Try again!",
                msg: "'\(newWord)' isn't a real word!"
            )
            return
        }
        guard wordIsNotRoot(answer) else {
            wordError(
                title: "Try again!",
                msg: "You're not wrong, but you get no points!"
            )
            return
        }
        guard wordIsLongEnough(answer) else {
            wordError(
                title: "Try again!",
                msg: "Enter a word that's at least 3 letters long."
            )
            return
        }

        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        hasFocus = true
    }

    func getScore() -> Double {
        let letterMultiplier = 1 +
            Double(usedWords.reduce(0) { $0 + $1.count }) * 0.01
        let rawScore = Double(usedWords.count) * letterMultiplier
        return round(rawScore * 1000) / 1000
    }

    var body: some View {
        NavigationStack {
            List {
                Group {
                    Text("Use the letters in ") +
                        Text("\n\(rootWord)").font(.largeTitle) +
                        Text("\nto create new words.")
                }
                .font(.title3)
                .listRowBackground(Color.white.opacity(0))
                .foregroundStyle(.white)
                Section {
                    TextField(
                        "Test",
                        text: $newWord,
                        prompt: Text("Enter your word").foregroundStyle(.gray)
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($hasFocus)
                    .foregroundStyle(.white)
                }.onSubmit(addNewWord)
                    .font(.title2)
                    .padding(8)
                    .listRowBackground(Color("FieldBG"))
                if usedWords.count > 0 {
                    Section {
                        Group {
                            Text("Score: \(String(format: "%.2f", getScore()))")
                                .font(.title)
                                +
                                Text(
                                    "\nFormula: <# words> * (1 + <# letters> / 100)"
                                )
                                .font(.footnote)
                        }
                    }
                    .listRowBackground(Color("FieldBG"))
                    .foregroundStyle(.white)
                }
                Section {
                    ForEach(Array(usedWords.enumerated()),
                            id: \.element)
                    { i, word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                            Spacer()
                            Text("\(usedWords.count - i)")
                        }
                        .foregroundStyle(.white)
                        .listRowBackground(Color("FieldBG"))
                    }
                }
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("Shucks, OK") {
                    newWord = ""
                    hasFocus = true
                }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("WordScramble")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                }
                /*
                 ToolbarItem(placement: .topBarTrailing) {
                     Button {
                         resetGame()
                     } {
                         Text("Restart").foregroundStyle(.white)
                     }
                 }
                  */
            }
            .toolbarBackground(Color("AppBG").opacity(0.9), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollContentBackground(.hidden)
            .background(Color("AppBG"))
        }
    }
}

#Preview {
    ContentView()
}
