import SwiftUI
import SwiftData

struct DailyEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var date = Date()
    @State private var weight = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Date
                    SectionHeader("Date")
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    // Weight
                    SectionHeader("Weight")
                    HStack {
                        Text("Weight")
                        Spacer(minLength: 12)
                        HStack(spacing: 6) {
                            TextField("", text: $weight)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .focused($focused)
                                .onChange(of: weight) { _, new in
                                    weight = numericFiltered(new)
                                }
                            Text("kg").foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                        )
                        .frame(minWidth: 140)
                    }

                    // Save
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
    }

    // MARK: - Helpers
    private func numericFiltered(_ s: String) -> String {
        let allowed = "0123456789.,"
        var filtered = s.filter { allowed.contains($0) }
        filtered = filtered.replacingOccurrences(of: ",", with: ".")
        // اسمح بنقطة واحدة فقط
        let parts = filtered.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
        if parts.count > 2 { filtered = parts[0] + "." + parts[1] }
        return String(filtered.prefix(8)) // حد للطول
    }

    private func toDouble(_ s: String) -> Double? {
        Double(s.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces))
    }

    private func saveAndClose() {
        guard let w = toDouble(weight) else { return }
        let m = Measurement(date: date, unit: "cm", weight: w)
        context.insert(m)
        try? context.save()
        focused = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }
}

