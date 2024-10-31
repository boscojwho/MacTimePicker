//
//  TimePickerStyle.swift
//
//
//  Created by Bosco Ho on 2024-10-31.
//

import SwiftUI

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public extension DatePickerStyle where Self == TimeIntervalPickerStyle {
    
    static func timeIntervalField(
        _ interval: Binding<TimeInterval>? = nil
    ) -> TimeIntervalPickerStyle {
        .init(interval: interval)
    }
}

public struct TimeIntervalPickerStyle: DatePickerStyle {
    @Binding var interval: TimeInterval
    public init(interval: Binding<TimeInterval>? = nil) {
        _interval = interval ?? .init(get: {
            return 0
        }, set: { _ in
            return
        })
    }
    public func makeBody(configuration: Configuration) -> some View {
#if os(macOS)
        TimePicker(
            selection: configuration.$selection,
            interval: $interval,
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
