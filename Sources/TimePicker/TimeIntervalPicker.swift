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
    @Binding var dateComponents: DateComponents
    init(
        component: TimePickerComponents,
        intervalRange: ClosedRange<TimeInterval> = 0...60,
        selection: Binding<DateComponents>
    ) {
        self.component = component
        self.intervalRange = intervalRange
        _input = .init(wrappedValue: "00")
        _tempInput = .init(wrappedValue: "00")
        _dateComponents = selection
    }
    
    @State private var input: String
    /// Resets to `00` (or equivalent) after timeout period ends.
    @State private var tempInput: String
    
    @State private var timer: Timer?
    @State private var resetTimer: Timer?
    
    @FocusState private var selected: Bool
    
    @FocusedValue(\.timePickerComponent) private var focusedComponent
    private var isFocused: Bool {
        guard selected else { return false }
        return focusedComponent == component
    }
    
    private enum Constants {
        static let defaultValue = "00"
        static let timeoutDuration: TimeInterval = 1.0
        static let maxDigits = 2
    }

    var body: some View {
        Text("\(input)")
            .font(.largeTitle)
            .animation(.none) { view in
                view.padding(2)
                    .background(isFocused ? .orange : .clear)
                    .clipShape(.rect(cornerRadius: 4))
            }
            .focusable()
            .focused($selected)
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
                    tempInput = Constants.defaultValue
                    input = Constants.defaultValue
                } else if validInterval <= intervalRange.upperBound {
                    print("entered \(validInterval)")
                    tempInput = String(newInput.suffix(Constants.maxDigits))
                    input = String(newInput.suffix(Constants.maxDigits))
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
                return increment()
            }
            .onKeyPress(.downArrow) {
                return decrement()
            }
            .onChange(of: input) { _, newValue in
                guard let intValue = Int(input) else {
                    input = Constants.defaultValue
                    fatalError()
                }
                setDateComponents(with: intValue)
            }
            .accessibilityLabel("\(component.description): \(input)")
            .accessibilityValue("\(input)")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    increment()
                case .decrement:
                    decrement()
                @unknown default:
                    break
                }
            }
    }
    
    @discardableResult
    private func increment() -> KeyPress.Result {
        guard let intValue = Int(input) else {
            print("ignored .upArrow")
            return .ignored
        }
        guard TimeInterval(intValue + 1) <= intervalRange.upperBound else {
            print("ignored .upArrow upper bound")
            return .ignored
        }
        input = String("0\(String(intValue + 1))".suffix(Constants.maxDigits))
        return .handled
    }
    
    @discardableResult
    private func decrement() -> KeyPress.Result {
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
    
    private func setDateComponents(with value: Int) {
        dateComponents = .init(
            hour: component == .hour ? value : nil,
            minute: component == .minute ? value : nil,
            second: component == .second ? value : nil
        )
        print("\(component) -> ", dateComponents)
    }
    
    private func enterTimeoutPeriod() {
        timer = .scheduledTimer(withTimeInterval: Constants.timeoutDuration, repeats: false) { _ in
            print("timeout ended")
            tempInput = Constants.defaultValue
            timer = nil
        }
    }
    
    private func enterResetCountdown() {
        resetTimer = .scheduledTimer(withTimeInterval: Constants.timeoutDuration, repeats: false) { _ in
            print("reset triggered")
            tempInput = Constants.defaultValue
            resetTimer = nil
        }
    }
}

#Preview {
    TimeIntervalPicker(
        component: .second,
        selection: .constant(.init(second: 0))
    )
    .frame(width: 280, height: 144)
}
#endif
