import SwiftUI

// MARK: - Home View
// The entry point for prayer
// Minimal, warm, intentional - not a dashboard

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var coordinator: RootCoordinator
    
    var body: some View {
        ZStack {
            // Background
            Color.screenBackground
                .ignoresSafeArea()
            
            // Subtle ambient warmth
            RadialGradient(
                colors: [
                    Color.deepEmber.opacity(0.3),
                    Color.charcoal.opacity(0)
                ],
                center: .bottom,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: FerventSpacing.section) {
                Spacer()
                
                // Logo / Brand
                brandSection
                
                Spacer()
                
                // Duration Selection
                durationSection
                
                Spacer()
                
                // Start Prayer Button
                startPrayerButton
                
                // Schedule Prayer (subtle)
                scheduleButton
                
                Spacer()
                    .frame(height: FerventSpacing.xl)
            }
            .padding(.horizontal, FerventSpacing.screenEdge)
        }
        .sheet(isPresented: $viewModel.showingTimePicker) {
            timePickerSheet
        }
        .task {
            // Request notification permissions on first launch
            await viewModel.requestNotificationPermission()
        }
    }
    
    // MARK: - Brand Section
    
    private var brandSection: some View {
        VStack(spacing: FerventSpacing.sm) {
            // Logo placeholder - the interlocked squares
            Image(systemName: "flame.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.ferventOrange, .warmAccent],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            
            Text("Fervent")
                .font(.ferventDisplay)
                .foregroundColor(.primaryText)
            
            Text("Tongues of Fire")
                .font(.ferventCaption)
                .foregroundColor(.secondaryText)
        }
    }
    
    // MARK: - Duration Section
    
    private var durationSection: some View {
        VStack(spacing: FerventSpacing.md) {
            Text("Prayer Duration")
                .font(.ferventLabel)
                .foregroundColor(.secondaryText)
            
            // Duration presets
            HStack(spacing: FerventSpacing.sm) {
                ForEach([
                    PrayerDurationPreset.fiveMinutes,
                    .tenMinutes,
                    .fifteenMinutes,
                    .thirtyMinutes
                ], id: \.self) { preset in
                    durationButton(preset)
                }
            }
            
            // Selected duration display
            Text(viewModel.formattedDuration)
                .font(.ferventTitle)
                .foregroundColor(.primaryText)
        }
    }
    
    private func durationButton(_ preset: PrayerDurationPreset) -> some View {
        Button {
            withAnimation(.ferventStandard) {
                viewModel.selectPreset(preset)
            }
        } label: {
            Text(preset.displayName)
                .font(.ferventCaption)
                .foregroundColor(
                    viewModel.selectedPreset == preset ? .charcoal : .secondaryText
                )
                .padding(.horizontal, FerventSpacing.md)
                .padding(.vertical, FerventSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            viewModel.selectedPreset == preset
                            ? Color.ferventOrange
                            : Color.charcoal.opacity(0.5)
                        )
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Start Prayer Button
    
    private var startPrayerButton: some View {
        Button {
            Task {
                await coordinator.startPrayer(duration: viewModel.selectedDuration)
            }
        } label: {
            HStack(spacing: FerventSpacing.sm) {
                Image(systemName: "flame")
                Text("Begin Prayer")
            }
            .font(.ferventButton)
            .foregroundColor(.charcoal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, FerventSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.ferventOrange, .warmAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: .ferventOrange.opacity(0.4), radius: 20, y: 10)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Schedule Button
    
    private var scheduleButton: some View {
        Button {
            viewModel.showingTimePicker = true
        } label: {
            HStack {
                Image(systemName: "clock")
                Text("Schedule Daily Prayer")
            }
            .font(.ferventCaption)
            .foregroundColor(.secondaryText)
        }
        .buttonStyle(.plain)
        .padding(.top, FerventSpacing.sm)
    }
    
    // MARK: - Time Picker Sheet
    
    private var timePickerSheet: some View {
        NavigationView {
            VStack(spacing: FerventSpacing.lg) {
                Text("Set Prayer Time")
                    .font(.ferventTitle)
                    .foregroundColor(.primaryText)
                
                DatePicker(
                    "Prayer Time",
                    selection: $viewModel.selectedPrayerTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Button {
                    Task {
                        await viewModel.schedulePrayerTime()
                    }
                } label: {
                    Text("Schedule")
                        .font(.ferventButton)
                        .foregroundColor(.charcoal)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, FerventSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.ferventOrange)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
            .padding()
            .background(Color.screenBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showingTimePicker = false
                    }
                    .foregroundColor(.ferventOrange)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationBackground(Color.screenBackground)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(RootCoordinator())
}
