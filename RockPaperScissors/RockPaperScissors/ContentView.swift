//
//  ContentView.swift
//  RockPaperScissors
//
//  Created by Evan Peterson on 7/7/24.
//

import SwiftUI

enum Move: CaseIterable {
    case Rock, Paper, Scissors
}

extension Move {
    func emojify() -> String {
        switch self {
        case .Rock:
            "💧"
        case .Paper:
            "🌱"
        case .Scissors:
            "🔥"
        }
    }
}

enum ScoreCondition: CaseIterable {
    case Win, Lose
}

enum Result {
    case Win, Lose, Tie
}

extension CaseIterable {
    static func random() -> Self {
        .allCases.randomElement()!
    }
}

struct MoveIcon: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 100))
            .padding(20)
            .background(.thinMaterial)
            .clipShape(.circle)
    }
}

struct ContentView: View {
    @State private var score = 0
    @State private var cpuMove: Move = .random()
    @State private var scoreCondition: ScoreCondition = .random()

    func playMove(_ move: Move) -> () -> Void {
        return {
            var result: Result
            if move == cpuMove {
                result = .Tie
            } else {
                switch move {
                case .Rock:
                    result = cpuMove == .Scissors ? .Win : .Lose
                case .Paper:
                    result = cpuMove == .Rock ? .Win : .Lose
                case .Scissors:
                    result = cpuMove == .Paper ? .Win : .Lose
                }
            }
            if (result == .Win && scoreCondition == .Win) ||
                (result == .Lose && scoreCondition == .Lose)
            {
                score += 1
            } else {
                score = max(score - 1, 0)
            }
            cpuMove = .random()
            scoreCondition = scoreCondition == .Win ? .Lose : .Win
        }
    }

    var body: some View {
        VStack {
            ZStack {
                Color(red: 0.3, green: 0.7, blue: 0.3)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Text("Showdown!")
                        .font(.title)
                        .foregroundStyle(.white)
                    Text("Score: \(score)")
                        .font(.title2)
                        .foregroundStyle(.white)
                    Text(cpuMove.emojify())
                        .modifier(MoveIcon())
                    Spacer()
                    Text(scoreCondition == .Win ? "is weak to ⁇" :
                        "is supereffective against ⁇")
                        .font(.title2)
                        .foregroundStyle(.white)
                    Spacer()
                }
            }
            Color(.black)
                .frame(height: 1)
            ZStack {
                Color(red: 0.3, green: 0.8, blue: 0.3)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Button(
                        Move.Paper.emojify(),
                        action: playMove(.Paper)
                    )
                    .modifier(MoveIcon())
                    HStack {
                        Spacer()
                        Button(
                            Move.Rock.emojify(),
                            action: playMove(.Rock)
                        )
                        .modifier(MoveIcon())
                        Spacer()
                        Button(
                            Move.Scissors.emojify(),
                            action: playMove(.Scissors)
                        )
                        .modifier(MoveIcon())
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
