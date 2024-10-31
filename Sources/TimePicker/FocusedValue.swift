//
//  FocusedValue.swift
//
//
//  Created by Bosco Ho on 2024-10-31.
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
