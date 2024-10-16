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
    
    let component: TimePickerComponents
    let intervalRange: ClosedRange<TimeInterval>
    init(
        component: TimePickerComponents,
        intervalRange: ClosedRange<TimeInterval> = 0...60
    ) {
        self.component = component
        self.intervalRange = intervalRange
        _input = .init(wrappedValue: "00")
        _tempInput = .init(wrappedValue: "00")
        _dateComponents = .init(
            wrappedValue: .init(
                hour: component == .hour ? 0 : nil,
                minute: component == .minute ? 0 : nil,
                second: component == .second ? 0 : nil
            )
        )
    }
    
    @State private var input: String
    /// Resets to `00` (or equivalent) after timeout period ends.
    @State private var tempInput: String
    
    @State private var timer: Timer?
    @State private var resetTimer: Timer?
    
    @State private var dateComponents: DateComponents
    
    @FocusedValue(\.timePickerComponent) private var focusedComponent
    private var isFocused: Bool {
        focusedComponent == component
    }

    var body: some View {
        Text("\(input)")
            .font(.largeTitle)
            .animation(.default.speed(2)) { view in
                view.padding(2)
                    .background(isFocused ? .orange : .clear)
                    .clipShape(.rect(cornerRadius: 4))
            }
            .focusable()
            .focusEffectDisabled(true)
            .onKeyPress(characters: .decimalDigits, phases: .up) { keyPress in
                let isTimedOut = timer?.isValid ?? false
                guard isTimedOut == false else {
                    print("timeout block -> \(isTimedOut)")
                    return .handled
                }
                
                let newInput = String((tempInput + keyPress.characters))
                guard let validInterval = TimeInterval(newInput), intervalRange.contains(validInterval) else {
                    print("enter timeout because invalid interval")
                    enterTimeoutPeriod()
                    return .handled
                }
                
                if validInterval == 0 {
                    print("entered 0 or 00")
                    tempInput = defaultInput
                    input = defaultInput
                } else if validInterval <= intervalRange.upperBound {
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
            .onKeyPress(.upArrow) {
                guard let intValue = Int(input) else {
                    print("ignored .upArrow")
                    return .ignored
                }
                guard TimeInterval(intValue + 1) <= intervalRange.upperBound else {
                    print("ignored .upArrow upper bound")
                    return .ignored
                }
                input = String("0\(String(intValue + 1))".suffix(2))
                return .handled
            }
            .onKeyPress(.downArrow) {
                guard let intValue = Int(input) else {
                    print("ignored .downArrow")
                    return .ignored
                }
                guard TimeInterval(intValue - 1) >= intervalRange.lowerBound else {
                    print("ignored .downArrow lower bound")
                    return .ignored
                }
                input = String("0\(String(intValue - 1))".suffix(2))
                return .handled
            }
            .onChange(of: input) { _, newValue in
                guard let intValue = Int(input) else {
                    fatalError()
                }
                setDateComponents(with: intValue)
            }
    }
    
    private func setDateComponents(with value: Int) {
        dateComponents = .init(
            hour: component == .hour ? value : nil,
            minute: component == .minute ? value : nil,
            second: component == .second ? value : nil
        )
        print("\(component) -> ", dateComponents)
    }
    
    private var defaultInput: String {
        return "00"
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
    TimeIntervalPicker(
        component: .second
    )
    .frame(width: 280, height: 144)
}
#endif
