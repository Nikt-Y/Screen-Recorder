import SwiftUI

struct SliderSettingView: View {
    let title: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    let step: Float
    let labels: [String]
    var onChange: ((Float) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
            
            CustomSlider(value: Binding(
                get: { value },
                set: { newValue in
                    value = newValue
                    onChange?(newValue)
                }
            ), range: range, step: step)
                .frame(height: 30)
            
            HStack {
                ForEach(labels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    if label != labels.last {
                        Spacer()
                    }
                }
            }
        }
    }
}

struct SettingsSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var settings: RecordingSettings
    var onSettingsUpdated: (RecordingSettings) -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Header with close button
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 40) {
                // Resolution slider
                SliderSettingView(
                    title: "Resolution",
                    value: $settings.resolutionSliderValue,
                    range: 1...4,
                    step: 1,
                    labels: settings.resolutionOptions,
                    onChange: { newValue in
                        onSettingsUpdated(settings)
                    }
                )
                
                // Bitrate slider
                SliderSettingView(
                    title: "Bitrate(Mbps)",
                    value: $settings.bitrateSliderValue,
                    range: 1...8,
                    step: 1,
                    labels: settings.bitrateOptions.map { String($0) },
                    onChange: { newValue in
                        onSettingsUpdated(settings)
                    }
                )
                
                // Framerate slider
                SliderSettingView(
                    title: "Framerate",
                    value: $settings.framerateSliderValue,
                    range: 1...5,
                    step: 1,
                    labels: settings.framerateOptions.map { String($0) },
                    onChange: { newValue in
                        onSettingsUpdated(settings)
                    }
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Home indicator
            Rectangle()
                .fill(Color.black)
                .frame(width: 134, height: 5)
                .cornerRadius(2.5)
                .padding(.bottom, 8)
        }
        .padding(.top, 16)
    }
}

struct SettingsSheetWrapper: View {
    @State private var measuredHeight: CGFloat = 450
    @Binding var settings: RecordingSettings
    var onSettingsUpdated: (RecordingSettings) -> Void
    
    var body: some View {
        IntrinsicHeightContainer {
            SettingsSheetView(settings: $settings, onSettingsUpdated: onSettingsUpdated)
        }
        .onPreferenceChange(SheetHeightPreferenceKey.self) { newHeight in
            if abs(newHeight - measuredHeight) > 1 {
                measuredHeight = newHeight
            }
        }
        .presentationDetents([.height(measuredHeight)])
    }
}
