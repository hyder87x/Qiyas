import SwiftUI

struct OnboardingView: View {
    @AppStorage("onboarding.done") private var onboardingDone: Bool = false

    @AppStorage("user.name")     private var name: String = ""
    @AppStorage("user.age")      private var ageYears: Int = 0
    @AppStorage("user.heightCm") private var heightCm: Double = 0
    @AppStorage("user.isMale")   private var isMale: Bool = true

    @State private var ageText = ""
    @State private var heightText = ""
    @FocusState private var focused: Bool

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
        && Int(ageText) != nil
        && (Double(heightText.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)

                    TextField("Age (years)", text: $ageText)
                        .keyboardType(.numberPad)
                        .onChange(of: ageText) { new in
                            ageText = new.filter(\.isNumber).prefix(3).description
                        }

                    TextField("Height (cm)", text: $heightText)
                        .keyboardType(.decimalPad)
                        .onChange(of: heightText) { new in
                            heightText = numericFiltered(new)
                        }

                    Picker("Sex", selection: $isMale) {
                        Text("Male").tag(true)
                        Text("Female").tag(false)
                    }
                    .pickerStyle(.segmented)
                }

                Section(footer: Text("You can edit this later from the User tab.")) {
                    Button {
                        saveAndContinue()
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canSave)
                }
            }
            .navigationTitle("Welcome")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = false }
                }
            }
            .onAppear {
                if ageYears > 0 { ageText = String(ageYears) }
                if heightCm > 0 { heightText = clean(heightCm) }
            }
        }
    }

    private func saveAndContinue() {
        ageYears = Int(ageText) ?? 0
        heightCm = Double(heightText.replacingOccurrences(of: ",", with: ".")) ?? 0
        onboardingDone = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

// MARK: - Utils shared locally
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

private func clean(_ v: Double) -> String {
    if v == 0 { return "" }
    return String(format: "%.1f", v)
}

