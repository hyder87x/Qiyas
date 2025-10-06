import SwiftUI
import SwiftData

struct WeeklyEntryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var unit = "cm"

    // نصوص الإدخال
    @State private var weight = ""
    @State private var waist  = ""
    @State private var hips   = ""
    @State private var chest  = ""
    @State private var neck   = ""     // NEW
    @State private var lArm   = ""
    @State private var rArm   = ""
    @State private var lThigh = ""
    @State private var rThigh = ""
    @State private var notes  = ""

    @FocusState private var focused: Bool

    private let units = ["cm", "in"]

    var body: some View {
        NavigationStack {
            Form {
                SectionHeaderView("Date")
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)

                SectionHeaderView("Unit")
                Picker("Unit", selection: $unit) {
                    ForEach(units, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.bottom, 6)

                SectionHeaderView("Body")
                VStack(spacing: 10) {
                    NumberRow(label: "Weight (kg)", text: $weight)
                    NumberRow(label: "Waist (\(unit))", text: $waist)
                    NumberRow(label: "Hips (\(unit))",  text: $hips)
                    NumberRow(label: "Chest (\(unit))", text: $chest)
                    NumberRow(label: "Neck (\(unit))",  text: $neck)   // NEW
                }

                SectionHeaderView("Arms")
                VStack(spacing: 10) {
                    NumberRow(label: "Left Arm (\(unit))",  text: $lArm)
                    NumberRow(label: "Right Arm (\(unit))", text: $rArm)
                }

                SectionHeaderView("Thighs")
                VStack(spacing: 10) {
                    NumberRow(label: "Left Thigh (\(unit))",  text: $lThigh)
                    NumberRow(label: "Right Thigh (\(unit))", text: $rThigh)
                }

                SectionHeaderView("Note")
                TextField("Optional note", text: $notes, axis: .vertical)
                    .lineLimit(1...3)
            }
            .navigationTitle("Weekly Entry")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = false }
                }
            }
        }
    }

    // حفظ السجل
    private func save() {
        let m = Measurement(
            date: date,
            unit: unit,
            weight: parse(weight),
            waist:  parse(waist),
            hips:   parse(hips),
            chest:  parse(chest),
            neck:   parse(neck),      // NEW
            leftArm:   parse(lArm),
            rightArm:  parse(rArm),
            leftThigh: parse(lThigh),
            rightThigh: parse(rThigh),
            notes: notes.isEmpty ? nil : notes
        )

        context.insert(m)
        try? context.save()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }

    private func parse(_ s: String) -> Double? {
        let cleaned = s.replacingOccurrences(of: ",", with: ".")
        guard let v = Double(cleaned) else { return nil }
        return v
    }
}

//
// MARK: - UI محلية داخل نفس الملف (ما تحتاج تعتمد على ملفات ثانية)
//

private struct SectionHeaderView: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased())
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }
}

private struct NumberRow: View {
    let label: String
    @Binding var text: String
    @FocusState private var focused: Bool

    var body: some View {
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
        let parts = filtered.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
        if parts.count > 2 {
            filtered = parts[0] + "." + parts[1]
        }
        return String(filtered.prefix(8))
    }
}

