//
//  SwiftUIView.swift
//  
//
//  Created by Bosco Ho on 2024-10-29.
//

import SwiftUI

/**
 ** INSTRUCTIONS **
 To move between time pickers, use TAB or SHIFT-TAB.
 To move between time components, use LEFT or RIGHT arrow keys.
 To change time component values, use UP or DOWN arrow keys.
 */
private struct ContentView: View {
    @State private var times: [Date] = [.init(), .init(), .init()]
    @State private var selectedInterval: TimeInterval = 0
    @FocusState private var focused: Bool
    var body: some View {
        Group {
            // MARK: - Initialize using TimePicker API
            LabeledContent("TimePicker") {
                Spacer()
                TimePicker(
                    selection: $times[0],
                    displayedComponents: [.hour, .minute, .second]
                )
            }
            // MARK: - Initialize using DatePicker API
            LabeledContent("DatePicker.timePickerStyle") {
                Spacer()
                DatePicker(
                    "Choose a time",
                    selection: $times[1],
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.timeIntervalField($selectedInterval))
            }
            // MARK: - Default SwiftUI DatePicker
            LabeledContent("DatePicker.stepperField") {
                Spacer()
                DatePicker(
                    "Choose a time",
                    selection: $times[2],
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.stepperField)
            }
            .focusEffectDisabled(false)
        }
        .scenePadding()
        #if DEBUG
        .onChange(of: times[0]) { oldValue, newValue in
            print("\(oldValue) -> \(newValue)")
        }
        .onChange(of: selectedInterval) { oldValue, newValue in
            print("selectedInterval: \(oldValue) -> \(newValue)")
        }
        #endif
    }
}

#Preview {
    ContentView()
}
