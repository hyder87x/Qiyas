import SwiftUI
import SwiftData

// MARK: - Main ME screen
struct MeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("My Profile") {
                    NavigationLink {
                        ProfileFormView()
                    } label: {
                        Label("Edit my profile", systemImage: "person.text.rectangle")
                    }
                }

                Section("Settings") {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Preferences", systemImage: "gearshape")
                    }
                }

                Section("Legal & About") {
                    NavigationLink {
                        StaticTextScreen(title: "Privacy Policy",
                                         text: "Your privacy matters. Add your real policy later.")
                    } label: {
                        Label("Privacy", systemImage: "lock.shield")
                    }

                    NavigationLink {
                        StaticTextScreen(title: "Terms of Use",
                                         text: "Add your real terms later.")
                    } label: {
                        Label("Terms & Conditions", systemImage: "doc.plaintext")
                    }

                    NavigationLink {
                        StaticTextScreen(title: "About",
                                         text: "Qiyas – track your body measurements. Version 0.1")
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("ME")
        }
    }
}

// MARK: - Profile form (SwiftData-backed)
struct ProfileFormView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]

    @State private var name = ""
    @State private var ageText = ""
    @State private var heightText = ""
    @State private var sex: Sex = .male

    // keyboard
    @FocusState private var focused: Bool

    private var profile: UserProfile {
        if let p = profiles.first { return p }
        let p = UserProfile()
        context.insert(p)
        try? context.save()
        return p
    }

    var body: some View {
        Form {
            Section("Basic info") {
                TextField("Name", text: $name)
                    .focused($focused)

                TextField("Age (years)", text: $ageText)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .onChange(of: ageText) { ageText = ageText.filter(\.isNumber) }

                TextField("Height (cm)", text: $heightText)
                    .keyboardType(.decimalPad)
                    .focused($focused)
                    .onChange(of: heightText) { heightText = numericFiltered(heightText) }

                Picker("Sex", selection: $sex) {
                    Text("Male").tag(Sex.male)
                    Text("Female").tag(Sex.female)
                }
                .pickerStyle(.segmented)
            }

            Section {
                Button {
                    save()
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            } footer: {
                Text("These values feed BMI / Navy on Today.")
            }
        }
        .navigationTitle("My Profile")
        .onAppear(perform: load)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focused = false }
            }
        }
    }

    private func load() {
        let p = profile
        name = p.name
        ageText = p.age.map(String.init) ?? ""
        heightText = p.heightCm.map { String(format: "%.0f", $0) } ?? ""
        sex = p.sex
    }

    private func save() {
        var changed = false
        let p = profile

        if p.name != name { p.name = name; changed = true }

        if let age = Int(ageText), age != p.age {
            p.age = age; changed = true
        } else if ageText.isEmpty, p.age != nil {
            p.age = nil; changed = true
        }

        if let h = Double(heightText), h != p.heightCm {
            p.heightCm = h; changed = true
        } else if heightText.isEmpty, p.heightCm != nil {
            p.heightCm = nil; changed = true
        }

        if p.sex != sex { p.sex = sex; changed = true }

        if changed {
            try? context.save()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    private func numericFiltered(_ s: String) -> String {
        let allowed = "0123456789.,"
        var t = s.filter { allowed.contains($0) }
        t = t.replacingOccurrences(of: ",", with: ".")
        let parts = t.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
        if parts.count > 2 { t = parts[0] + "." + parts[1] }
        return String(t.prefix(6))
    }
}

// MARK: - Settings
struct SettingsView: View {
    // وحدة القياس الافتراضية للتطبيق (تستخدم لاحقًا في الإدخال/العرض)
    @AppStorage("defaultUnit") private var defaultUnit: String = "cm"
    // اللغة (placeholder – لا نغيّر لغة النظام فعليًا الآن)
    @AppStorage("appLanguage") private var appLanguage: String = "System"

    private let languages = ["System", "English", "Arabic"]
    private let units = ["cm", "in"]

    var body: some View {
        Form {
            Section("Preferred unit") {
                Picker("Unit", selection: $defaultUnit) {
                    ForEach(units, id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)
            }

            Section("Language") {
                Picker("Language", selection: $appLanguage) {
                    ForEach(languages, id: \.self) { Text($0) }
                }
            }

            Section(footer: Text("Language picker is a placeholder. You can wire it to in-app localization later.")) {
                EmptyView()
            }
        }
        .navigationTitle("Settings")
    }
}

// MARK: - Static pages
struct StaticTextScreen: View {
    let title: String
    let text: String
    var body: some View {
        ScrollView {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(title)
    }
}

