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

public enum TimePickerComponents: Hashable, CaseIterable {
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
    func dateComponents() -> DateComponents {
        .init(
            hour: self == .hour ? 0 : nil,
            minute: self == .minute ? 0 : nil,
            second: self == .second ? 0 : nil
        )
    }
}

public struct TimePicker: View {
    let displayedComponents: [TimePickerComponents]
    @Binding var selection: Date
    @State private var dateComponents: [DateComponents]
    public init(
        selection: Binding<Date>,
        displayedComponents: [TimePickerComponents]
    ) {
        _selection = selection
        self.displayedComponents = displayedComponents
        _dateComponents = .init(wrappedValue: displayedComponents.map {
            $0.dateComponents()
        })
    }
    
    @FocusState private var focus: TimePickerComponents?
    
    @State private var components: [TimePickerComponents: DateComponents] = [:]
    
    public var body: some View {
        HStack(spacing: 2) {
            let components = Array(displayedComponents.enumerated())
            ForEach(
                components,
                id: \.offset
            ) { component in
                let element: TimePickerComponents = component.element
                let offset: Int = component.offset
                TimeIntervalPicker(
                    component: element,
                    selection: $dateComponents[offset]
                )
                .focused($focus, equals: component.element)
                .focusedValue(\.timePickerComponent, focus)
//                .onChange(of: $dateComponents[offset].wrappedValue) { _, newValue in
//                    let value: DateComponents = newValue
//                    components[element] = value
//                }
                
                if component.offset < (components.count - 1) {
                    let separator = separator(
                        after: component.element,
                        components: components.map { $0.element }
                    )
                    Text(verbatim: separator)
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
                print("\(String(describing: self.focus))")
            case .right:
                print("Right: \(focus) -> \(focus.next())")
                self.focus = focus.next()
                print("\(String(describing: self.focus))")
            default:
                print("Unsupported arrow direction")
                return
            }
        }
        #if DEBUG
        .onChange(of: dateComponents) { oldValue, newValue in
            print("old -> \(oldValue)")
            print("new -> \(newValue)")
//            let hasHour = displayedComponents.contains { $0 == .hour }
//            let hasMinute = displayedComponents.containts { $0 == .minute }
//            let hasSecond = displayedComponents.containts { $0 == .second }
//            let mergedComponents = DateComponents(hour: hasHour ? newValue, minute: <#T##Int?#>, second: <#T##Int?#>)
        }
        #endif
    }
    
    private func separator(
        after component: TimePickerComponents,
        components: [TimePickerComponents]
    ) -> String {
        guard components.count > 1 else {
            return ""
        }
        guard let index = components.firstIndex(of: component) else {
            return ""
        }
        let nextIndex = components.index(after: index)
        if components[nextIndex] == .second {
            return "."
        }
        return ":"
    }
}

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public extension DatePickerStyle where Self == TimeIntervalPickerStyle {
    
    static var timeIntervalField: TimeIntervalPickerStyle { .init() }
}

public struct TimeIntervalPickerStyle: DatePickerStyle {
    public func makeBody(configuration: Configuration) -> some View {
#if os(macOS)
        TimePicker(
            selection: configuration.$selection,
            displayedComponents: TimePickerComponents.allCases
        )
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
    TimePicker(
        selection: .constant(.now),
        displayedComponents: TimePickerComponents.allCases
    )
    .padding()
}
