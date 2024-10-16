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

        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        hasFocus = true
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($hasFocus)
                }.onSubmit(addNewWord)
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }.navigationTitle(rootWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("Shucks, OK") {
                        newWord = ""
                        hasFocus = true
                    }
                } message: {
                    Text(errorMessage)
                }
        }
    }
}

#Preview {
    ContentView()
}
