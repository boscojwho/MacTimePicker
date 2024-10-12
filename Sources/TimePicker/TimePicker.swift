//
//  TimePicker.swift
//  NotchBar
//
//  Created by Bosco Ho on 2024-10-01.
//

import SwiftUI

struct FocusedTimePickerComponent: FocusedValueKey {
    typealias Value = TimePickerComponents
}

extension FocusedValues {
    var timePickerComponent: FocusedTimePickerComponent.Value? {
        get { self[FocusedTimePickerComponent.self] }
        set { self[FocusedTimePickerComponent.self] = newValue }
    }
}

enum TimePickerComponents: Hashable, CaseIterable {
    case hour, minute, second
    func next() -> Self {
        switch self {
        case .hour:
            return .minute
        case .minute:
            return .second
        case .second:
            return .hour
        }
    }
    func previous() -> Self {
        switch self {
        case .hour:
            return .second
        case .minute:
            return .hour
        case .second:
            return .minute
        }
    }
}

struct TimePicker: View {
    let displayedComponents: [TimePickerComponents]
    init(displayedComponents: [TimePickerComponents]) {
        self.displayedComponents = displayedComponents
        _focused = .init(wrappedValue: .init(
            repeating: false,
            count: displayedComponents.count
        ))
    }
    
    @State private var focused: [Bool]
    @FocusState private var focus: TimePickerComponents?
    
    var body: some View {
        HStack(spacing: 2) {
            let components = Array(displayedComponents.enumerated())
            ForEach(
                components,
                id: \.offset
            ) { component in
                TimeIntervalPicker(
                    component: component.element,
                    isFocused: $focused[component.offset]
                )
                .focused($focus, equals: component.element)
                .focusedValue(\.timePickerComponent, focus)
                .onTapGesture {
                    for (offset, value) in $focused.enumerated() {
                        if offset == component.offset {
                            value.wrappedValue = true
                        } else {
                            value.wrappedValue = false
                        }
                    }
                }
                
                if component.offset < (components.count - 1) {
                    Text(
                        ":"
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
        .onMoveCommand { direction in
            guard let focus else {
                print("No focus")
                return
            }
            switch direction {
            case .left:
                print("Left: \(focus) -> \(focus.previous())")
                self.focus = focus.previous()
                print("\(self.focus)")
            case .right:
                print("Right: \(focus) -> \(focus.next())")
                self.focus = focus.next()
                print("\(self.focus)")
            default:
                print("Unsupported arrow direction")
                return
            }
        }
//        .focusable(true)
//        .focusEffectDisabled(true)
//        .onKeyPress(.leftArrow) {
//            let focusedIndex = focused.firstIndex { value in value == true }
//            guard let focusedIndex else {
//                /// Focus right-most.
//                print("<- focus right most")
//                focused[focused.endIndex] = true
//                return .ignored
//            }
//            let previous = focusedIndex.advanced(by: -1)
//            guard previous >= focused.startIndex else {
//                return .ignored
//            }
//            print("focus previous \(previous)")
//            for (offset, _) in focused.enumerated() {
//                focused[offset] = false
//            }
//            focused[previous] = true
//            return .handled
//        }
//        .onKeyPress(.rightArrow) {
//            let focusedIndex = focused.firstIndex { value in value == true }
//            guard let focusedIndex else {
//                /// Focus left-most.
//                print("-> focus left most")
//                focused[focused.startIndex] = true
//                return .ignored
//            }
//            let next = focusedIndex.advanced(by: 1)
//            guard next < focused.endIndex else {
//                return .ignored
//            }
//            print("focus next \(next)")
//            for (offset, _) in focused.enumerated() {
//                focused[offset] = false
//            }
//            focused[next] = true
//            return .handled
//        }
    }
    
    private func separator(
        after component: TimePickerComponents,
        components: [TimePickerComponents]
    ) -> String {
        return ":"
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
        TimePicker(displayedComponents: TimePickerComponents.allCases)
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
    TimePicker(displayedComponents: TimePickerComponents.allCases)
        .padding()
}
