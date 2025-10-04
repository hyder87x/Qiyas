import SwiftUI
import SwiftData

struct DailyEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var date = Date()
    @State private var weight = ""
    @FocusState private var focused: Bool

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                SectionHeader("Date")
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .trailing)

                SectionHeader("Weight")
                BoxedNumberRow(label: "Weight (kg)", text: $weight)
                    .focused($focused)

                Button(action: saveAndClose) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(weight.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(16)
        }
        .navigationTitle("Daily Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focused = false }
            }
        }
    }

    private func toDouble(_ s: String) -> Double? {
        Double(s.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces))
    }

    private func saveAndClose() {
        let m = Measurement(date: date, unit: "cm", weight: toDouble(weight))
        context.insert(m)
        try? context.save()
        focused = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }
}
