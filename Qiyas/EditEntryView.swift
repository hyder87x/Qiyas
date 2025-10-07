import SwiftUI
import SwiftData

struct EditEntryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable var entry: Measurement

    @State private var weight = ""
    @State private var chest = ""
    @State private var hips = ""
    @State private var waist = ""
    @State private var leftArm = ""
    @State private var rightArm = ""
    @State private var leftThigh = ""
    @State private var rightThigh = ""
    @State private var unit = "cm"
    @State private var notes = ""

    @FocusState private var focused: Bool

    var body: some View {
        Form {
            Section("Date & Unit") {
                DatePicker("Date",
                           selection: Binding(get: { entry.date }, set: { entry.date = $0 }),
                           displayedComponents: .date)

                Picker("Unit", selection: $unit) {
                    Text("cm").tag("cm")
                    Text("in").tag("in")
                }
                .pickerStyle(.segmented)
            }

            Section("Measurements") {
                numberField("Weight", text: $weight, suffix: "kg")
                numberField("Chest", text: $chest)
                numberField("Hips", text: $hips)
                numberField("Waist", text: $waist)
                numberField("Left Arm", text: $leftArm)
                numberField("Right Arm", text: $rightArm)
                numberField("Left Thigh", text: $leftThigh)
                numberField("Right Thigh", text: $rightThigh)
            }

            Section("Notes") {
                TextField("Notes", text: $notes, axis: .vertical)
            }

            Button {
                save()
            } label: {
                Text("Save Changes")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Edit Entry")
        .onAppear { loadFromModel() }
        .toolbar {
            // === شريط أدوات يظهر فوق الكيبورد: زر إخفاء + Done ===
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    focused = false
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .font(.title3)
                        .accessibilityLabel("Hide Keyboard")
                }

                Spacer()

                Button("Done") { focused = false }
                    .fontWeight(.semibold)
            }
        }
    }

    // MARK: - Helpers
    private func loadFromModel() {
        unit = entry.unit
        weight = fmt(entry.weight)
        chest  = fmt(entry.chest)
        hips   = fmt(entry.hips)
        waist  = fmt(entry.waist)
        leftArm  = fmt(entry.leftArm)
        rightArm = fmt(entry.rightArm)
        leftThigh  = fmt(entry.leftThigh)
        rightThigh = fmt(entry.rightThigh)
        notes = entry.notes ?? ""
    }

    private func fmt(_ v: Double?) -> String {
        guard let v else { return "" }
        return String(format: "%.1f", v)
    }

    private func parse(_ s: String) -> Double? {
        let cleaned = s
            .replacingOccurrences(of: ",", with: ".")
            .filter { "0123456789.".contains($0) }
        if cleaned.filter({ $0 == "." }).count > 1 { return nil }
        return Double(cleaned)
    }

    private func numberField(_ title: String, text: Binding<String>, suffix: String? = nil) -> some View {
        HStack {
            Text(title)
            Spacer(minLength: 12)
            HStack(spacing: 6) {
                TextField("", text: text)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused($focused)
                    .onChange(of: text.wrappedValue) { newValue in
                        let filtered = newValue
                            .replacingOccurrences(of: ",", with: ".")
                            .filter { "0123456789.".contains($0) }
                        // اسمح بنقطة واحدة فقط
                        let parts = filtered.split(
                            separator: ".",
                            maxSplits: 2,
                            omittingEmptySubsequences: false
                        )
                        let sanitized: Substring = parts.count > 2 ? parts[0] + "." + parts[1] : Substring(filtered)
                        text.wrappedValue = String(sanitized.prefix(8))
                    }
                if let s = suffix {
                    Text(s).foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.35), lineWidth: 1)
            )
            .frame(minWidth: 140)
        }
    }

    private func save() {
        entry.unit       = unit
        entry.weight     = parse(weight)
        entry.chest      = parse(chest)
        entry.hips       = parse(hips)
        entry.waist      = parse(waist)
        entry.leftArm    = parse(leftArm)
        entry.rightArm   = parse(rightArm)
        entry.leftThigh  = parse(leftThigh)
        entry.rightThigh = parse(rightThigh)
        entry.notes      = notes.isEmpty ? nil : notes

        do {
            try context.save()
            focused = false
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            dismiss()
        } catch {
            print("Save failed: \(error)")
        }
    }
}

