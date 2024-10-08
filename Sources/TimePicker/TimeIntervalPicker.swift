//
//  TimeIntervalPicker.swift
//  NotchBar
//
//  Created by Bosco Ho on 2024-09-24.
//

#if os(macOS)
import SwiftUI
import Combine

struct TimeIntervalPicker: View {
    enum InputError: Error {
        case invalidValue
    }
    
    @Binding var isFocused: Bool
    @State private var input: String = "00"
    @State private var timer: Timer?
    @State private var resetTimer: Timer?
    
    /// Resets to `00` after timeout period ends.
    @State private var tempInput = "00"
    
//    @Environment(\.isFocused) var focusState

    var body: some View {
        Text("\(input)")
            .font(.largeTitle)
            .animation(.default.speed(2)) { view in
                view.padding(2)
                    .background(isFocused ? .orange : .clear)
                    .clipShape(.rect(cornerRadius: 4))
            }
            .focusable(true)
            .focusEffectDisabled(true)
            .onKeyPress(characters: .decimalDigits, phases: .up) { keyPress in
                let isTimedOut = timer?.isValid ?? false
                guard isTimedOut == false else {
                    print("timeout block -> \(isTimedOut)")
                    return .handled
                }
                
                let newInput = String((tempInput + keyPress.characters))
                guard let validInterval = TimeInterval(newInput), (0...60).contains(validInterval) else {
                    print("enter timeout because invalid interval")
                    enterTimeoutPeriod()
                    return .handled
                }
                
                if validInterval == 0 {
                    print("entered 0 or 00")
                    tempInput = "00"
                    input = "00"
                } else if validInterval <= 60 {
                    print("entered \(validInterval)")
                    tempInput = String(newInput.suffix(2))
                    input = String(newInput.suffix(2))
                } else {
                    assertionFailure()
                }
                
                guard validInterval < 10 else {
                    print("enter timeout because valid interval is two non-zero digits")
                    enterTimeoutPeriod()
                    return .handled
                }
                
                enterResetCountdown()
                return .handled
            }
    }
    
    private func enterTimeoutPeriod() {
        timer = .scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            print("timeout ended")
            tempInput = "00"
            timer = nil
        }
    }
    
    private func enterResetCountdown() {
        resetTimer = .scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            print("reset triggered")
            tempInput = "00"
            resetTimer = nil
        }
    }
}

#Preview {
    TimeIntervalPicker(isFocused: .constant(true))
        .frame(width: 280, height: 144)
}
#endif
