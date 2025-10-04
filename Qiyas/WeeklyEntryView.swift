import SwiftUI
import SwiftData

struct WeeklyEntryView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("unit") private var unit = "cm"

    @State private var date = Date()

    @State private var waist = ""
    @State private var hips = ""
    @State private var chest = ""
    @State private var weight = ""
    @State private var rightArm = ""
    @State private var leftArm = ""
    @State private var rightThigh = ""
    @State private var leftThigh = ""
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
                    BoxedNumberRow(label: "Waist", text: $waist)
                    BoxedNumberRow(label: "Hips", text: $hips)
                    BoxedNumberRow(label: "Chest", text: $chest)
                    BoxedNumberRow(label: "Weight (kg)", text: $weight)
                    BoxedNumberRow(label: "Right Arm", text: $rightArm)
                    BoxedNumberRow(label: "Left Arm", text: $leftArm)
                    BoxedNumberRow(label: "Right Thigh", text: $rightThigh)
                    BoxedNumberRow(label: "Left Thigh", text: $leftThigh)
                }

                HStack(alignment: .center) {
                    Text("Notes")
                    Spacer(minLength: 12)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.secondary.opacity(0.35), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemBackground))
                            )
                        TextField("", text: $notes, axis: .vertical)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
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

    private func toDouble(_ s: String) -> Double? {
        Double(s.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces))
    }

    private func saveAndClear() {
        let m = Measurement(
            date: date,
            unit: unit,
            waist: toDouble(waist),
            hips: toDouble(hips),
            chest: toDouble(chest),
            weight: toDouble(weight),
            rightArm: toDouble(rightArm),
            leftArm: toDouble(leftArm),
            rightThigh: toDouble(rightThigh),
            leftThigh: toDouble(leftThigh),
            notes: notes.isEmpty ? nil : notes
        )
        context.insert(m)
        try? context.save()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        // clear
        [ $waist, $hips, $chest, $weight, $rightArm, $leftArm, $rightThigh, $leftThigh ]
            .forEach { $0.wrappedValue = "" }
        notes = ""
        date = Date()
        focused = false
    }
}
