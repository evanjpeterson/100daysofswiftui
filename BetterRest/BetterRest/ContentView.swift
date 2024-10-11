//
//  ContentView.swift
//  BetterRest
//
//  Created by Evan Peterson on 10/10/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    static var defaultWakeTime: Date {
        let wakeUpToday = Calendar.current.date(
            bySettingHour: 8,
            minute: 0,
            second: 0,
            of: Date.now
        ) ?? .now
        let wakeUpTomorrow = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: wakeUpToday
        ) ?? .now
        return wakeUpTomorrow
    }

    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeCups = 2

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    func calculateBedtime() -> Date {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents(
                [.hour, .minute],
                from: wakeUp
            )
            let hour = (components.hour ?? 8) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeCups)
            )

            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime
            alertMessage =
                "\(sleepTime.formatted(date: .omitted, time: .shortened))"
        } catch {
            showingAlert = true
            alertTitle = "Oops!"
            alertMessage =
                "Sorry, there was a problem calculating your recommended bedtime."
            return .now
        }
    }

    private var bedtime: Date {
        calculateBedtime()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("When would you prefer to wake up?")
                        .font(.headline)
                        .listRowSeparator(.hidden)
                    DatePicker(
                        "Please select a time",
                        selection: $wakeUp,
                        displayedComponents: .hourAndMinute
                    ).frame(
                        maxWidth: .infinity,
                        alignment: .trailing
                    )
                    .labelsHidden()
                }
                Section {
                    Text("How many hours of sleep would you like?")
                        .font(.headline)
                        .listRowSeparator(.hidden)
                    Stepper(
                        "\(sleepAmount.formatted()) hours",
                        value: $sleepAmount,
                        in: 4...12,
                        step: 0.5
                    )
                }
                Section {
                    Text(
                        "How many cups of coffee do you typically drink per day?"
                    )
                    .font(.headline)
                    .listRowSeparator(.hidden)

                    Picker(
                        "Please select a number of cups",
                        selection: $coffeeCups
                    ) {
                        ForEach(0...20, id: \.self) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .labelsHidden()
                }
                Section {
                    Text("Your ideal bedtime is...")
                        .font(.headline)
                    Text(
                        "\(bedtime.formatted(date: .omitted, time: .shortened))"
                    )
                    .font(.largeTitle)
                }
            }
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    ContentView()
}
