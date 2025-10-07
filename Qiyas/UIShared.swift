import SwiftUI

// MARK: - Global types / helpers shared by views

public enum Sex: String, Codable, CaseIterable, Identifiable {
    case male
    case female

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .male:   return "Male"
        case .female: return "Female"
        }
    }
}

// Section title used in multiple screens
public struct SectionHeader: View {
    public let title: String
    public init(_ title: String) { self.title = title }

    public var body: some View {
        Text(title.uppercased())
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }
}

// Reusable right-aligned numeric text field row
public struct BoxedNumberRow: View {
    public let label: String
    @Binding public var text: String
    @FocusState private var focused: Bool

    public init(label: String, text: Binding<String>) {
        self.label = label
        self._text  = text
    }

    public var body: some View {
        HStack {
            Text(label)
            Spacer(minLength: 12)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.systemBackground))
                    )
                TextField("", text: $text)
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .multilineTextAlignment(.trailing)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .focused($focused)
                    .onChange(of: text) { new in
                        text = numericFiltered(new)
                    }
            }
            .frame(maxWidth: 220, minHeight: 40)
        }
    }

    private func numericFiltered(_ s: String) -> String {
        let allowed = "0123456789.,"
        var filtered = s.filter { allowed.contains($0) }
        filtered = filtered.replacingOccurrences(of: ",", with: ".")
        // نقطة واحدة فقط
        let parts = filtered.split(
            separator: ".", maxSplits: 2, omittingEmptySubsequences: false
        )
        if parts.count > 2 { filtered = parts[0] + "." + parts[1] }
        return String(filtered.prefix(8))
    }
}

