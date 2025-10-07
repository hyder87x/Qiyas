import SwiftUI
import Foundation

// MARK: - Types

public enum Sex: String, Codable, CaseIterable {
    case male, female
}

// MARK: - Health helpers

/// BMI = weight(kg) / (height(m)^2)
public func bmi(weightKg: Double?, heightCm: Double?) -> Double? {
    guard let w = weightKg, let h = heightCm, w > 0, h > 0 else { return nil }
    let meters = h / 100.0
    return w / (meters * meters)
}

/// Navy Body Fat %
/// male:  495 / (1.0324 - 0.19077*log10(waist - neck) + 0.15456*log10(height)) - 450
/// female:495 / (1.29579 - 0.35004*log10(waist + hip - neck) + 0.22100*log10(height)) - 450
public func navyBodyFatPercent(
    sex: Sex,
    heightCm: Double?,
    neckCm: Double?,
    waistCm: Double?,
    hipCm: Double?
) -> Double? {
    guard
        let h = heightCm, let n = neckCm, let w = waistCm,
        h > 0, n > 0, w > 0
    else { return nil }

    let log10 = { (x: Double) -> Double? in x > 0 ? Foundation.log10(x) : nil }

    switch sex {
    case .male:
        guard let ln = log10(w - n), let lh = log10(h) else { return nil }
        let density = 1.0324 - 0.19077 * ln + 0.15456 * lh
        let bf = 495.0 / density - 450.0
        return bf.isFinite ? bf : nil

    case .female:
        guard let hip = hipCm, hip > 0,
              let ln = log10(w + hip - n),
              let lh = log10(h) else { return nil }
        let density = 1.29579 - 0.35004 * ln + 0.22100 * lh
        let bf = 495.0 / density - 450.0
        return bf.isFinite ? bf : nil
    }
}

// MARK: - Shared UI

public struct SectionHeader: View {
    public var title: String
    public init(_ title: String) { self.title = title }
    public var body: some View {
        Text(title.uppercased())
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }
}

public struct BoxedNumberRow: View {
    public let label: String
    @Binding public var text: String
    @FocusState private var focused: Bool

    public init(label: String, text: Binding<String>) {
        self.label = label
        self._text = text
    }

    public var body: some View {
        HStack(alignment: .center) {
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
            }
            .frame(maxWidth: 220, minHeight: 40)
        }
    }
}

