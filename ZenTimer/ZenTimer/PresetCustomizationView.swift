import SwiftUI

struct PresetCustomizationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: TimerViewModel
    @State private var editingPreset: TimerPreset?
    @State private var isAddingNew = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 251/255, green: 146/255, blue: 60/255),
                        Color(red: 239/255, green: 68/255, blue: 68/255),
                        Color(red: 220/255, green: 38/255, blue: 38/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Customize Presets")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 8)

                        VStack(spacing: 0) {
                            ForEach(viewModel.presets) { preset in
                                PresetRow(preset: preset, onTap: {
                                    editingPreset = preset
                                }, onDelete: {
                                    viewModel.deletePreset(id: preset.id)
                                })

                                if preset.id != viewModel.presets.last?.id {
                                    Divider()
                                        .background(.white.opacity(0.2))
                                        .padding(.leading, 64)
                                }
                            }
                        }
                        .background(.white.opacity(0.15))
                        .cornerRadius(12)

                        Button(action: {
                            isAddingNew = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Add Preset")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.15))
                            .cornerRadius(12)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                }
            }
            .sheet(item: $editingPreset) { preset in
                PresetEditorView(preset: preset, onSave: { updated in
                    viewModel.updatePreset(updated)
                })
            }
            .sheet(isPresented: $isAddingNew) {
                PresetEditorView(preset: nil, onSave: { newPreset in
                    viewModel.addPreset(newPreset)
                })
            }
        }
    }
}

private struct PresetRow: View {
    let preset: TimerPreset
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: preset.icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(preset.color.opacity(0.4))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(preset.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Text("\(preset.minutes) min")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct PresetEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let isEditing: Bool
    let onSave: (TimerPreset) -> Void

    @State private var name: String
    @State private var minutes: Int
    @State private var selectedIcon: String
    @State private var selectedColor: String
    private let presetId: UUID

    private let availableIcons = [
        "leaf.fill", "moon.fill", "sparkles", "star.fill",
        "flame.fill", "heart.fill", "bolt.fill", "sun.max.fill",
        "cloud.fill", "drop.fill", "wind", "mountain.2.fill"
    ]

    private let availableColors: [(name: String, color: Color)] = [
        ("green", .green), ("blue", .blue), ("purple", .purple),
        ("orange", .orange), ("red", .red), ("pink", .pink),
        ("yellow", .yellow), ("teal", .teal)
    ]

    init(preset: TimerPreset?, onSave: @escaping (TimerPreset) -> Void) {
        self.onSave = onSave
        if let preset = preset {
            self.isEditing = true
            self.presetId = preset.id
            _name = State(initialValue: preset.name)
            _minutes = State(initialValue: preset.minutes)
            _selectedIcon = State(initialValue: preset.icon)
            _selectedColor = State(initialValue: preset.colorName)
        } else {
            self.isEditing = false
            self.presetId = UUID()
            _name = State(initialValue: "")
            _minutes = State(initialValue: 10)
            _selectedIcon = State(initialValue: "leaf.fill")
            _selectedColor = State(initialValue: "blue")
        }
    }

    private var selectedColorValue: Color {
        availableColors.first { $0.name == selectedColor }?.color ?? .blue
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 251/255, green: 146/255, blue: 60/255),
                        Color(red: 239/255, green: 68/255, blue: 68/255),
                        Color(red: 220/255, green: 38/255, blue: 38/255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Preview
                        VStack(spacing: 8) {
                            Image(systemName: selectedIcon)
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .frame(width: 64, height: 64)
                                .background(
                                    Circle()
                                        .fill(selectedColorValue.opacity(0.4))
                                )
                            Text(name.isEmpty ? "Preset Name" : name)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("\(minutes) min")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 8)

                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.headline)
                                .foregroundColor(.white)
                            TextField("Preset name", text: $name)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(.white.opacity(0.15))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .onChange(of: name) { _, newValue in
                                    if newValue.count > 20 {
                                        name = String(newValue.prefix(20))
                                    }
                                }
                        }

                        // Minutes picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration")
                                .font(.headline)
                                .foregroundColor(.white)
                            HStack {
                                Button(action: { if minutes > 1 { minutes -= 1 } }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Spacer()
                                Text("\(minutes) min")
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: { if minutes < 99 { minutes += 1 } }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(12)
                            .background(.white.opacity(0.15))
                            .cornerRadius(10)
                        }

                        // Icon picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Icon")
                                .font(.headline)
                                .foregroundColor(.white)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        Image(systemName: icon)
                                            .font(.system(size: 22))
                                            .foregroundColor(.white)
                                            .frame(width: 44, height: 44)
                                            .background(
                                                Circle()
                                                    .fill(selectedIcon == icon
                                                          ? selectedColorValue.opacity(0.5)
                                                          : .white.opacity(0.1))
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(.white.opacity(selectedIcon == icon ? 0.8 : 0), lineWidth: 2)
                                            )
                                    }
                                }
                            }
                            .padding(12)
                            .background(.white.opacity(0.15))
                            .cornerRadius(10)
                        }

                        // Color picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color")
                                .font(.headline)
                                .foregroundColor(.white)
                            HStack(spacing: 12) {
                                ForEach(availableColors, id: \.name) { item in
                                    Button(action: { selectedColor = item.name }) {
                                        Circle()
                                            .fill(item.color)
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Circle()
                                                    .stroke(.white, lineWidth: selectedColor == item.name ? 3 : 0)
                                            )
                                    }
                                }
                            }
                            .padding(12)
                            .background(.white.opacity(0.15))
                            .cornerRadius(10)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let preset = TimerPreset(
                            id: presetId,
                            name: name,
                            minutes: minutes,
                            icon: selectedIcon,
                            colorName: selectedColor
                        )
                        onSave(preset)
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    PresetCustomizationView()
        .environmentObject(TimerViewModel())
}
