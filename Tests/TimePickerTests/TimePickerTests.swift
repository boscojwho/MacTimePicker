import XCTest
@testable import TimePicker

final class TimePickerTests: XCTestCase {
    func testNextPreviousCycle() {
        XCTAssertEqual(TimePickerComponents.hour.next(), TimePickerComponents.minute)
        XCTAssertEqual(TimePickerComponents.minute.next(), TimePickerComponents.second)
        XCTAssertEqual(TimePickerComponents.second.next(), TimePickerComponents.hour)
        
        XCTAssertEqual(TimePickerComponents.hour.previous(), TimePickerComponents.second)
        XCTAssertEqual(TimePickerComponents.minute.previous(), TimePickerComponents.hour)
        XCTAssertEqual(TimePickerComponents.second.previous(), TimePickerComponents.minute)
    }
    
    func testDateComponents() {
        let hourComponents = TimePickerComponents.hour.dateComponents()
        XCTAssertEqual(hourComponents.hour, 0)
        XCTAssertNil(hourComponents.minute)
        XCTAssertNil(hourComponents.second)
        
        let minuteComponents = TimePickerComponents.minute.dateComponents()
        XCTAssertEqual(minuteComponents.minute, 0)
        XCTAssertNil(minuteComponents.hour)
        XCTAssertNil(minuteComponents.second)
        
        let secondComponents = TimePickerComponents.second.dateComponents()
        XCTAssertEqual(secondComponents.second, 0)
        XCTAssertNil(secondComponents.hour)
        XCTAssertNil(secondComponents.minute)
    }
}
