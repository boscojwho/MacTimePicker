//
//  TimePicker.swift
//  NotchBar
//
//  Created by Bosco Ho on 2024-10-01.
//

import SwiftUI

struct TimePickerComponents: OptionSet, CaseIterable {
    let rawValue: UInt
    
    static let hours = TimePickerComponents(rawValue: 1 << 0)
    static let minutes = TimePickerComponents(rawValue: 1 << 1)
    static let seconds = TimePickerComponents(rawValue: 1 << 2)
    
    static let all: TimePickerComponents = [.hours, .minutes, .seconds]
    static var allCases: [TimePickerComponents] = [.hours, .minutes, .seconds]
    
    func array() -> [Self] {
        TimePickerComponents
            .allCases
            .filter { $0.rawValue & self.rawValue != 0 }
    }
}

struct TimePicker: View {
    let displayedComponents: TimePickerComponents
    init(displayedComponents: TimePickerComponents) {
        self.displayedComponents = displayedComponents
        _focused = .init(wrappedValue: .init(
            repeating: false,
            count: displayedComponents.array().count
        ))
    }
    
    @State private var focused: [Bool]
    
    var body: some View {
        HStack(spacing: 2) {
            let components = Array(displayedComponents.array().enumerated())
            ForEach(
                components,
                id: \.offset
            ) { component in
                TimeIntervalPicker(
                    component: component.element,
                    isFocused: $focused[component.offset]
                )
                .onTapGesture {
                    for (offset, value) in $focused.enumerated() {
                        if offset == component.offset {
                            value.wrappedValue = true
                        } else {
                            value.wrappedValue = false
                        }
                    }
                }
                
                if components.count > 1, component.offset < components.count - 1 {
                    Text(
                        separator(
                            after: component,
                            components: components
                        )
                    )
                    .font(.title)
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    .background.shadow(
                        .inner(
                            color: .secondary.opacity(0.5),
                            radius: 2
                        )
                    )
                )
        )
        .focusable(true)
        .focusEffectDisabled(true)
        .onKeyPress(.leftArrow) {
            let focusedIndex = focused.firstIndex { value in value == true }
            guard let focusedIndex else {
                /// Focus right-most.
                print("<- focus right most")
                focused[focused.endIndex] = true
                return .ignored
            }
            let previous = focusedIndex.advanced(by: -1)
            guard previous >= focused.startIndex else {
                return .ignored
            }
            print("focus previous \(previous)")
            for (offset, _) in focused.enumerated() {
                focused[offset] = false
            }
            focused[previous] = true
            return .handled
        }
        .onKeyPress(.rightArrow) {
            let focusedIndex = focused.firstIndex { value in value == true }
            guard let focusedIndex else {
                /// Focus left-most.
                print("-> focus left most")
                focused[focused.startIndex] = true
                return .ignored
            }
            let next = focusedIndex.advanced(by: 1)
            guard next < focused.endIndex else {
                return .ignored
            }
            print("focus next \(next)")
            for (offset, _) in focused.enumerated() {
                focused[offset] = false
            }
            focused[next] = true
            return .handled
        }
    }
    
    private func separator(
        after component: EnumeratedSequence<[TimePickerComponents]>.Element,
        components: [EnumeratedSequence<[TimePickerComponents]>.Element]
    ) -> String {
        let nextComponent = components[component.offset.advanced(by: 1)]
        let lhs = nextComponent.element.rawValue
        let rhs = TimePickerComponents.seconds.rawValue
        if lhs == rhs {
            return "."
        } else {
            return ":"
        }
    }
}

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension DatePickerStyle where Self == TimeIntervalPickerStyle {
    
    static var timeIntervalField: TimeIntervalPickerStyle { .init() }
}

struct TimeIntervalPickerStyle: DatePickerStyle {
    func makeBody(configuration: Configuration) -> some View {
#if os(macOS)
        TimePicker(displayedComponents: .all)
#else
        DatePicker(
            selection: configuration.selection,
            displayedComponents: configuration.displayedComponents,
            label: configuration.label
        )
#endif
    }
}

#Preview {
    TimePicker(displayedComponents: .all)
        .padding()
}
