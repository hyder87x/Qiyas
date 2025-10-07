import SwiftUI

/// شريط أدوات يظهر فوق الكيبورد يحتوي زر لإخفائه.
struct KeyboardDismissToolbar: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        // إغلاق الكيبورد
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .imageScale(.large)
                    }
                    .accessibilityLabel("Hide Keyboard")
                }
            }
    }
}

extension View {
    /// استخدمها على أي View يحتوي TextField ليظهر زر إخفاء الكيبورد.
    func keyboardDismissToolbar() -> some View {
        self.modifier(KeyboardDismissToolbar())
    }
}
