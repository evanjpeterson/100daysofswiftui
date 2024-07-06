//
//  ContentView.swift
//  ViewsAndModifiers
//
//  Created by Evan Peterson on 7/1/24.
//

import SwiftUI

struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundStyle(.blue)
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Working Title")
                .titleified()
        }
    }
}

extension View {
    func titleified() -> some View {
        modifier(Title())
    }
}

#Preview {
    ContentView()
}
