//
//  TimePicker.swift
//  NotchBar
//
//  Created by Bosco Ho on 2024-10-01.
//

import SwiftUI

public struct TimePicker: View {
    let displayedComponents: [TimePickerComponents]
    @Binding var selection: Date
    @Binding var interval: TimeInterval
    @State private var dateComponents: [DateComponents]
    @State private var components: [TimePickerComponents: DateComponents]
    public init(
        selection: Binding<Date>,
        interval: Binding<TimeInterval>? = nil,
        displayedComponents: [TimePickerComponents]
    ) {
        _selection = selection
        _interval = interval ?? .init(get: {
            return -1
        }, set: { _ in
            // no-op
            return
        })
        self.displayedComponents = displayedComponents
        _dateComponents = .init(wrappedValue: displayedComponents.map {
            $0.dateComponents()
        })
        var comps: [TimePickerComponents: DateComponents] = [:]
        for comp in displayedComponents {
            comps[comp] = comp.dateComponents()
        }
        _components = .init(wrappedValue: comps)
    }
    
    @State private var pickedInterval: TimeInterval = 0
    
    @FocusState private var focus: TimePickerComponents?
        
    let baselineDate = Date.now
    
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
        .onChange(of: dateComponents) { oldValue, newValue in
            let calendar = Calendar.autoupdatingCurrent
            var comps = DateComponents()
            for comp in newValue {
                comps.hour = comp.hour ?? comps.hour
                comps.minute = comp.minute ?? comps.minute
                comps.second = comp.second ?? comps.second
            }
            let date = calendar.date(
                byAdding: comps,
                to: baselineDate,
                wrappingComponents: false)
            selection = date ?? baselineDate
            pickedInterval = date?.timeIntervalSince(baselineDate) ?? 0
            
            #if DEBUG
//            print("old -> \(oldValue)")
//            print("new -> \(newValue)")
//            print("merged -> \(comps)")
//            print(baselineDate)
//            print(date)
//            print(date?.timeIntervalSince(baselineDate))
            #endif
        }
        .onChange(of: pickedInterval) { oldValue, newValue in
            print("pickedInterval: \(oldValue) -> \(newValue)")
        }
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

#Preview {
    TimePicker(
        selection: .constant(.now),
        displayedComponents: TimePickerComponents.allCases
    )
    .padding()
}
