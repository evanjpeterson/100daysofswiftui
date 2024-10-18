//
//  ContentView.swift
//  Animations
//
//  Created by Evan Peterson on 10/18/24.
//

import SwiftUI

struct ContentView: View {
    @State private var animationAmount = 0.0

    var body: some View {
        print(animationAmount)

        return VStack {
            /*
             Stepper(
                 "Scale amount",
                 value: $animationAmount.animation(),
                 in: 1...10
             )
             Spacer()
              */
            Button("Tap Me") {
                withAnimation(.spring(duration: 1.0, bounce: 0.3)) {
                    animationAmount += 360
                }
            }
            .padding(50)
            .background(.red)
            .foregroundStyle(.white)
            .clipShape(.circle)
            .rotation3DEffect(
                .degrees(animationAmount),
                axis: (x: 1, y: 0, z: 0)
            )
            // .scaleEffect(animationAmount)
            /*
             .overlay(
                 Circle()
                     .stroke(.red)
                     .scaleEffect(animationAmount)
                     .opacity(2 - animationAmount)
                     .animation(
                         .easeInOut(duration: 1.4)
                             .repeatForever(autoreverses: false),
                         value: animationAmount
                     )
             )
             .onAppear {
                 animationAmount = 2
             }
              */
        }
    }
}

#Preview {
    ContentView()
}
