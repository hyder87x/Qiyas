import SwiftUI
import SwiftData

struct WeeklyEntryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var unit = "cm"

    @State private var weight = ""
    @State private var chest = ""
    @State private var hips = ""
    @State private var waist = ""
    @State private var leftArm = ""
    @State private var rightArm = ""
    @State private var leftThigh = ""
    @State private var rightThigh = ""
    @State private var notes = ""

    @FocusState private var focused: Bool

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                SectionHeader("Date & Unit")

                HStack {
                    Text("Date")
                    Spacer(minLength: 12)
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }

                HStack {
                    Text("Unit")
                    Spacer(minLength: 12)
                    Picker("", selection: $unit) {
                        Text("cm").tag("cm")
                        Text("in").tag("in")
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 180)
                }

                SectionHeader("Body Measurements")
                Group {
                    row("Weight", text: $weight, suffix: "kg")
                    row("Chest", text: $chest)
                    row("Hips", text: $hips)
                    row("Waist", text: $waist)
                    row("Left Arm", text: $leftArm)
                    row("Right Arm", text: $rightArm)
                    row("Left Thigh", text: $leftThigh)
                    row("Right Thigh", text: $rightThigh)
                }

                HStack(alignment: .center) {
                    Text("Notes")
                    Spacer(minLength: 12)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemBackground)))
                        TextField("", text: $notes, axis: .vertical)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(.horizontal, 10).padding(.vertical, 8)
                            .multilineTextAlignment(.trailing)
                            .focused($focused)
                    }
                    .frame(maxWidth: 240, minHeight: 40)
                }

                Button(action: saveAndClear) {
                    Text("Save Weekly Entry")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(16)
        }
        .navigationTitle("Weekly Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focused = false }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func row(_ title: String, text: Binding<String>, suffix: String? = nil) -> some View {
        HStack(alignment: .center) {
            Text(title)
            Spacer(minLength: 12)
            HStack(spacing: 6) {
                TextField("", text: text)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused($focused)
                    .onChange(of: text.wrappedValue) { _, newValue in
                        let filtered = newValue
                            .replacingOccurrences(of: ",", with: ".")
                            .filter { "0123456789.".contains($0) }
                        let parts = filtered.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
                        let sanitized = parts.count > 2 ? parts[0] + "." + parts[1] : Substring(filtered)
                        text.wrappedValue = String(sanitized.prefix(8))
                    }
                if let s = suffix {
                    Text(s).foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.35), lineWidth: 1))
            .frame(maxWidth: 220, minHeight: 40)
        }
    }

    private func parse(_ s: String) -> Double? {
        let cleaned = s.replacingOccurrences(of: ",", with: ".")
            .filter { "0123456789.".contains($0) }
        if cleaned.filter({ $0 == "." }).count > 1 { return nil }
        return Double(cleaned)
    }

    private func saveAndClear() {
        let m = Measurement(
            date: date,
            unit: unit,
            weight: parse(weight),
            chest: parse(chest),
            hips: parse(hips),
            waist: parse(waist),
            leftArm: parse(leftArm),
            rightArm: parse(rightArm),
            leftThigh: parse(leftThigh),
            rightThigh: parse(rightThigh),
            notes: notes.isEmpty ? nil : notes
        )
        context.insert(m)
        try? context.save()
        focused = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        [ $weight, $chest, $hips, $waist, $leftArm, $rightArm, $leftThigh, $rightThigh ].forEach { $0.wrappedValue = "" }
        notes = ""
        date = Date()
    }
}

