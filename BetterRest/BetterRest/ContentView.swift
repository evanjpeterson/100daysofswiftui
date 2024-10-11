//
//  ContentView.swift
//  BetterRest
//
//  Created by Evan Peterson on 10/10/24.
//

import CoreML
import SwiftUI

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

struct ContentView: View {
    @State private var wakeUp = wakeUpTomorrow
    @State private var sleepAmount = 8.0
    @State private var coffeeCups = 1

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    func calculateBedtime() {
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
            alertTitle = "Your ideal bedtime is..."
            alertMessage =
                "\(sleepTime.formatted(date: .omitted, time: .shortened))"
        } catch {
            alertTitle = "Oops!"
            alertMessage =
                "Sorry, there was a problem calculating your recommended bedtime."
        }
        showingAlert = true
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("When would you prefer to wake up?")
                    .font(.headline)
                DatePicker(
                    "Please enter a time",
                    selection: $wakeUp,
                    displayedComponents: .hourAndMinute
                ).labelsHidden()
                Text("How many hours of sleep would you like?")
                    .font(.headline)
                Stepper(
                    "\(sleepAmount.formatted()) hours",
                    value: $sleepAmount,
                    in: 4...12,
                    step: 0.5
                )
                Text("How many cups of coffee do you drink per day?")
                    .font(.headline)
                Stepper(
                    "\(coffeeCups) cup\(coffeeCups != 1 ? "s" : "")",
                    value: $coffeeCups,
                    in: 0...20
                )
            }
            .padding(32)
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
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
