import SwiftUI
import SwiftData

struct WeeklyEntryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // لو عندك إعدادات لغة/وحدات، غيّر القيمة الابتدائية هنا
    @State private var date = Date()
    @State private var unit = "cm"

    // أهم 4
    @State private var weight = ""   // kg دائماً
    @State private var waist  = ""
    @State private var hips   = ""
    @State private var neck   = ""

    // الأذرع (قابلة للطي)
    @State private var showArms = false
    @State private var leftArm = ""
    @State private var rightArm = ""
    @State private var leftForearm = ""
    @State private var rightForearm = ""

    // الأرجل (قابلة للطي)
    @State private var showLegs = false
    @State private var leftThigh = ""
    @State private var rightThigh = ""
    @State private var leftKnee = ""
    @State private var rightKnee = ""

    // أخريات
    @State private var chest = ""
    @State private var shoulder = ""
    @State private var notes = ""

    @FocusState private var focused: Bool
    private let lengthUnits = ["cm", "in"]

    var body: some View {
        NavigationStack {
            Form {
                // التاريخ + الوحدة
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Picker("Length unit", selection: $unit) {
                        ForEach(lengthUnits, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                // أهم 4
                Section("Primary") {
                    NumberRow(label: "Weight (kg)", text: $weight, keyboard: .decimalPad)
                    NumberRow(label: "Waist (\(unit))", text: $waist)
                    NumberRow(label: "Hips (\(unit))",  text: $hips)
                    NumberRow(label: "Neck (\(unit))",  text: $neck)
                }

                // الأذرع
                Section {
                    Toggle(isOn: $showArms.animation(.easeInOut)) {
                        Label("Arms", systemImage: "chevron.down.circle\(showArms ? ".fill" : "")")
                    }
                    if showArms {
                        NumberRow(label: "Left Arm (\(unit))",  text: $leftArm)
                        NumberRow(label: "Right Arm (\(unit))", text: $rightArm)
                        NumberRow(label: "Left Forearm (\(unit))",  text: $leftForearm)
                        NumberRow(label: "Right Forearm (\(unit))", text: $rightForearm)
                    }
                }

                // الأرجل
                Section {
                    Toggle(isOn: $showLegs.animation(.easeInOut)) {
                        Label("Legs", systemImage: "chevron.down.circle\(showLegs ? ".fill" : "")")
                    }
                    if showLegs {
                        NumberRow(label: "Left Thigh (\(unit))",  text: $leftThigh)
                        NumberRow(label: "Right Thigh (\(unit))", text: $rightThigh)
                        NumberRow(label: "Left Knee (\(unit))",  text: $leftKnee)
                        NumberRow(label: "Right Knee (\(unit))", text: $rightKnee)
                    }
                }

                // صدر / كتف
                Section("Upper Body") {
                    NumberRow(label: "Chest (\(unit))",    text: $chest)
                    NumberRow(label: "Shoulder (\(unit))", text: $shoulder)
                }

                // ملاحظات + حفظ
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(1...3)

                    Button {
                        save()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canSave)
                }
            }
            .navigationTitle("Weekly Entry")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = false }
                }
            }
        }
    }

    // MARK: - Validation
    private var canSave: Bool {
        // على الأقل واحد من الحقول الأساسية موجود
        return parse(weight) != nil
            || parse(waist) != nil
            || parse(hips)  != nil
            || parse(neck)  != nil
    }

    // MARK: - Actions
    private func save() {
        let entry = BodyEntry(
            date: date,
            unit: unit,
            weight: parse(weight),
            waist:  parse(waist),
            hips:   parse(hips),
            neck:   parse(neck),
            leftArm:      parse(leftArm),
            rightArm:     parse(rightArm),
            leftForearm:  parse(leftForearm),
            rightForearm: parse(rightForearm),
            leftThigh:    parse(leftThigh),
            rightThigh:   parse(rightThigh),
            leftKnee:     parse(leftKnee),
            rightKnee:    parse(rightKnee),
            chest:        parse(chest),
            shoulder:     parse(shoulder),
            notes: notes.isEmpty ? nil : notes
        )

        context.insert(entry)
        try? context.save()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        focused = false
        dismiss()
    }

    private func parse(_ s: String) -> Double? {
        let clean = s
            .replacingOccurrences(of: ",", with: ".")
            .filter { "0123456789.".contains($0) }
        // نقطة واحدة فقط
        if clean.filter({ $0 == "." }).count > 1 { return nil }
        return Double(clean)
    }
}

// MARK: - Reusable Row (محلي داخل الملف)
private struct NumberRow: View {
    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .decimalPad
    @FocusState private var focused: Bool

    var body: some View {
        HStack {
            Text(label)
            Spacer(minLength: 12)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                TextField("", text: $text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .multilineTextAlignment(.trailing)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .focused($focused)
                    .onChange(of: text) { new in
                        text = filtered(new)
                    }
            }
            .frame(maxWidth: 220, minHeight: 40)
        }
    }

    private func filtered(_ s: String) -> String {
        let allowed = "0123456789.,"
        var f = s.filter { allowed.contains($0) }
        f = f.replacingOccurrences(of: ",", with: ".")
        let parts = f.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
        if parts.count > 2 { f = parts[0] + "." + parts[1] }
        return String(f.prefix(8))
    }
}

