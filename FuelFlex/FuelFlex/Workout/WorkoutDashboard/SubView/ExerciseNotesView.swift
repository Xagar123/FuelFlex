import SwiftUI

struct ExerciseNotesView: View {
    @Binding var notes: String
    let onDismiss: () -> Void

    private let maxChars = 200
    private let quickTags = [
        "Keep elbows tucked",
        "Go slow on eccentric",
        "Felt shoulder pain",
        "Increase weight next time"
    ]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Exercise Notes")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ColorTheme.textSecondary)
                        .font(.title3)
                }
            }

            ZStack(alignment: .topLeading) {
                TextEditor(text: $notes)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(ColorTheme.background)
                    .cornerRadius(10)
                    .onChange(of: notes) { _, newValue in
                        if newValue.count > maxChars {
                            notes = String(newValue.prefix(maxChars))
                        }
                    }

                if notes.isEmpty {
                    Text("Add form cues, notes...")
                        .foregroundColor(ColorTheme.textSecondary.opacity(0.6))
                        .font(.subheadline)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }

            HStack {
                Text("\(notes.count)/\(maxChars)")
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickTags, id: \.self) { tag in
                        Button {
                            let separator = notes.isEmpty ? "" : "\n"
                            let proposed = notes + separator + tag
                            notes = String(proposed.prefix(maxChars))
                        } label: {
                            Text(tag)
                                .font(.caption)
                                .foregroundColor(ColorTheme.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(ColorTheme.primary.opacity(0.12))
                                .cornerRadius(8)
                        }
                    }
                }
            }

            Button(action: onDismiss) {
                Text("Save")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(ColorTheme.buttonGradient)
                    .cornerRadius(10)
            }
        }
        .padding(20)
        .background(ColorTheme.surface)
        .cornerRadius(16)
        .padding(24)
    }
}
