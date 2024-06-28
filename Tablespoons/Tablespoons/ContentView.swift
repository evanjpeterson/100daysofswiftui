//
//  ContentView.swift
//  Tablespoons
//
//  Created by Evan Peterson on 6/24/24.
//

import SwiftUI

enum Measurement: String, CaseIterable {
    case tsp, tbsp, flOz = "fl oz", c, pt, qt, ml, l
}

func getLabel(_ msmt: Measurement) -> String {
    switch msmt {
    case .tsp: "teaspoons"
    case .tbsp: "tablespoons"
    case .flOz: "fluid ounces"
    case .c: "cups"
    case .pt: "pints"
    case .qt: "quarts"
    case .ml: "milliliters"
    case .l: "liters"
    }
}

// Everything gets converted into cups and then from cups into the target measurement.
func getConversion(_ msmt: Measurement) -> Double {
    switch msmt {
    case .tsp: 48
    case .tbsp: 16
    case .flOz: 8
    case .c: 1
    case .pt: 0.5
    case .qt: 0.25
    case .ml: 236.588
    case .l: 0.236588
    }
}

struct ContentView: View {
    @State private var fromUnit: Measurement = .tbsp
    @State private var toUnit: Measurement = .ml
    @State private var value: Double = 2.0

    @FocusState private var valueIsFocused: Bool

    private var convertedValue: Double {
        let cups = value / getConversion(fromUnit)
        return cups * getConversion(toUnit)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("From \(getLabel(fromUnit))") {
                    Picker("From units", selection: $fromUnit) {
                        ForEach(Measurement.allCases, id: \.rawValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    TextField("From value", value: $value, format: .number)
                        .keyboardType(.decimalPad)
                        .focused($valueIsFocused)
                        .toolbar {
                            if valueIsFocused {
                                Button("Done") {
                                    valueIsFocused = false
                                }
                            }
                        }
                }
                Section("To \(getLabel(toUnit))") {
                    Picker("To units", selection: $toUnit) {
                        ForEach(Measurement.allCases, id: \.rawValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(convertedValue, format: .number.rounded(increment: 0.01))
                }
            }
            .navigationTitle("Tablewhats?")
        }
    }
}

#Preview {
    ContentView()
}
