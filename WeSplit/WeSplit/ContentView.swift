//
//  ContentView.swift
//  WeSplit
//
//  Created by Evan Peterson on 6/23/24.
//

import SwiftUI

struct ContentView: View {
    let tipPercentages = [10, 15, 18, 20, 25, 0]
    let currencyCode = Locale.current.currency?.identifier ?? "USD"

    @State private var checkAmount = 0.0
    @State private var numberOfPeople = 0
    @State private var tipPercentage = 20
    @State private var customTipPercentage = 0
    @State private var showCustomTip = false

    @FocusState private var amountIsFocused: Bool

    private var tipScalar: Double {
        1.0 + Double(tipPercentage > 0 ? tipPercentage : customTipPercentage) *
            0.01
    }

    private var total: Double {
        checkAmount * tipScalar
    }

    private var perPerson: Double {
        total / Double(numberOfPeople + 2)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Bill") {
                    TextField(
                        "Amount",
                        value: $checkAmount,
                        format: .currency(code: currencyCode)
                    )
                    .keyboardType(.decimalPad)
                    .focused($amountIsFocused)
                    .toolbar {
                        if amountIsFocused {
                            Button("Done") {
                                amountIsFocused = false
                            }
                        }
                    }
                    Picker("Split how many ways?", selection: $numberOfPeople) {
                        ForEach(2..<100) {
                            Text("\($0)")
                        }
                    }
                }
                Section("Tip percentage") {
                    Picker("Tip percentage", selection: $tipPercentage) {
                        ForEach(tipPercentages, id: \.self) {
                            if $0 <= 0 {
                                Text("X%")
                            } else {
                                Text($0, format: .percent)
                            }
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: tipPercentage) {
                        if tipPercentage <= 0 {
                            showCustomTip = true
                        }
                    }
                    if showCustomTip {
                        Picker(
                            "Custom tip percentage",
                            selection: $customTipPercentage
                        ) {
                            ForEach(0..<101) {
                                Text($0, format: .percent)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    } else {
                        EmptyView()
                    }
                }
                Section("Total") {
                    Text(total, format: .currency(code: currencyCode))
                        .foregroundStyle(total == checkAmount && total > 0 ?
                            .red : .primary)
                }
                Section("Split amount") {
                    Text(perPerson, format: .currency(code: currencyCode))
                }
            }
            .navigationTitle("WeSplit")
        }
    }
}

#Preview {
    ContentView()
}
