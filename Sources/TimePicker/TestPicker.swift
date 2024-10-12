import SwiftUI

enum FocusableField: Hashable {
    case firstName
    case lastName
}

struct FocusUsingEnumView: View {
    @FocusState private var focus: FocusableField?
    
    @State private var firstName = ""
    @State private var lastName = ""
    
    var body: some View {
        HStack {
            Text("First Name")
                .focusable()
                .focused($focus, equals: .firstName)
                .onKeyPress(.upArrow, phases: .up) { keyPress in
                    print("UP - first name")
                    return .handled
                }
                .onKeyPress(.downArrow, phases: .up) { keyPress in
                    print("DOWN - first name")
                    return .handled
                }
            Text("Last Name")
                .focusable()
                .focused($focus, equals: .lastName)
                .onKeyPress(.upArrow, phases: .up) { keyPress in
                    print("UP - last name")
                    return .handled
                }
                .onKeyPress(.downArrow, phases: .up) { keyPress in
                    print("DOWN - last name")
                    return .handled
                }
                .onKeyPress(characters: .decimalDigits, phases: .up) { keyPress in
                    print(keyPress.characters)
                    return .handled
                }
            
            Button("Save") {
                if firstName.isEmpty {
                    focus = .firstName
                }
                else if lastName.isEmpty {
                    focus = .lastName
                }
                else {
                    focus = nil
                }
            }
        }
        .onMoveCommand { direction in
            guard let focus else {
                print("No focus")
                return
            }
            guard direction == .left || direction == .right else {
                return
            }
            if focus == .firstName {
                print("first -> last")
                self.focus = .lastName
            } else {
                print("last -> first")
                self.focus = .firstName
            }
        }
    }
}

#Preview {
    FocusUsingEnumView()
}
