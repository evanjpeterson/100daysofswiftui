//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Evan Peterson on 6/25/24.
//

import SwiftUI

let questionsPerGame = 8

struct FlagImage: View {
    var country: String

    var body: some View {
        Image(country)
            .clipShape(.rect(cornerRadius: 16.0))
            .shadow(radius: 4)
    }
}

struct ContentView: View {
    @State private var showingResult = false
    @State private var showingFinalScore = false
    @State private var questionsRemaining = questionsPerGame - 1
    @State private var score = 0
    @State var correctAnswer = Int.random(in: 0...2)
    @State private var userAnswer = 0
    @State var countries = [
        "Estonia",
        "France",
        "Germany",
        "Ireland",
        "Italy",
        "Nigeria",
        "Poland",
        "Spain",
        "UK",
        "Ukraine",
        "US",
    ].shuffled()

    var userIsCorrect: Bool {
        userAnswer == correctAnswer
    }

    func handleTap(_ number: Int) {
        userAnswer = number
        if userIsCorrect {
            score += 1
        }
        if questionsRemaining > 0 {
            showingResult = true
        } else {
            showingFinalScore = true
        }
    }

    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        questionsRemaining -= 1
    }

    func restartGame() {
        score = 0
        questionsRemaining = questionsPerGame
        askQuestion()
    }

    var body: some View {
        ZStack {
            Color.blue
            LinearGradient(
                colors: [.blue, .cyan, .mint],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            RadialGradient(stops: [
                .init(
                    color: Color(red: 0.1, green: 0.2, blue: 0.45),
                    location: 0.4
                ),
                .init(
                    color: Color(red: 0.1, green: 0.4, blue: 0.85),
                    location: 0.4
                ),
            ], center: .bottom, startRadius: 50, endRadius: 100)
                .ignoresSafeArea()
            VStack {
                Spacer()
                VStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Text("Tap the flag of")
                            .foregroundStyle(.white)
                            .font(.subheadline.weight(.heavy))
                        Text(countries[correctAnswer])
                            .foregroundStyle(.white)
                            .font(.largeTitle.weight(.semibold))
                    }
                    ForEach(0..<3) { number in
                        Button {
                            handleTap(number)
                        } label: {
                            FlagImage(country: countries[number])
                        }
                    }
                }
                Text("Score: \(score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                    .padding(.top, 40)
                Spacer()
            }
        }
        .alert(
            userIsCorrect ? "Correct!" : "Oops!",
            isPresented: $showingResult
        ) {
            Button("Continue", action: askQuestion)
        } message: {
            Text(userIsCorrect ? "Good thinking!" :
                "That's the flag of \(countries[userAnswer]).")
        }
        .alert("That's the game!", isPresented: $showingFinalScore) {
            Button("Play again?", action: restartGame)
        } message: {
            Text(
                "You scored \(score) / \(questionsPerGame)."
            )
        }
    }
}

#Preview {
    ContentView()
}
