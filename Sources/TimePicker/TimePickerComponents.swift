//
//  TimePickerComponents.swift
//
//
//  Created by Bosco Ho on 2024-10-31.
//

import Foundation

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
