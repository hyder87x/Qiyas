import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            // ===== Tab 1: Add Entry =====
            AddEntryHomeView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Add Entry")
                }

            // ===== Tab 2: Results (History) =====
            HistoryView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Results")
                }

            // ===== Tab 3: User / Profile =====
            UserView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("User")
                }
        }
    }
}

// MARK: - Home with horizontal slides (Daily / Weekly)
private struct AddEntryHomeView: View {
    @State private var page = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("My Measurements")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // Slides
                TabView(selection: $page) {
                    EntrySlideCard(
                        title: "Daily Entry",
                        subtitle: "Quickly log today's weight",
                        systemImage: "scalemass",
                        tint: .blue,
                        destination: AnyView(DailyEntryView())
                    )
                    .tag(0)

                    EntrySlideCard(
                        title: "Weekly Entry",
                        subtitle: "Log waist, hips, arms, thighs, chest and weight",
                        systemImage: "calendar",
                        tint: .green,
                        destination: AnyView(WeeklyEntryView())
                    )
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 210)
                .padding(.horizontal, 8)

                // Dots
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { i in
                        Circle()
                            .fill(i == page ? Color.primary : Color.secondary.opacity(0.35))
                            .frame(width: i == page ? 10 : 8, height: i == page ? 10 : 8)
                            .animation(.easeInOut(duration: 0.2), value: page)
                            .onTapGesture { withAnimation { page = i } }
                    }
                }
                .padding(.bottom, 8)

                Spacer(minLength: 0)
            }
        }
    }
}

private struct EntrySlideCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let destination: AnyView

    var body: some View {
        NavigationLink {
            destination
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(
                        colors: [tint.opacity(0.18), Color(.secondarySystemBackground)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.secondary.opacity(0.15), lineWidth: 1)
                    )

                HStack(spacing: 16) {
                    ZStack {
                        Circle().fill(tint.opacity(0.18)).frame(width: 64, height: 64)
                        Image(systemName: systemImage)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(tint)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(title).font(.headline)
                        Text(subtitle).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.footnote).foregroundStyle(.tertiary)
                }
                .padding(18)
            }
            .frame(height: 200)
            .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reusable UI Pieces used by entry screens
struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title)
            .font(.subheadline).fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }
}

struct BoxedNumberRow: View {
    let label: String
    @Binding var text: String

    var body: some View {
        HStack(alignment: .center) {
            Text(label)
            Spacer(minLength: 12)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.secondary.opacity(0.35), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                    )
                TextField("", text: $text)
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .multilineTextAlignment(.trailing)
            }
            .frame(maxWidth: 220, minHeight: 40)
        }
    }
}
