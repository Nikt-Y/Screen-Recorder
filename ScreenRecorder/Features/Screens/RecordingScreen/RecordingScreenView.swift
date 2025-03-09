import SwiftUI

struct RecordingScreenView: View {
    @StateObject var viewModel: RecordingScreenViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Screen recording")
                    .foregroundColor(.black)
                    .font(.adaptiveFont(size: 25, fontName: "PlusJakartaSans-Regular_ExtraBold"))
                
                Spacer()
                
                Button {
                    viewModel.openAppSettings()
                } label: {
                    Image("gearShape")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 29)
                }
            }
            .padding(.top, 34)
            .padding(.horizontal, 24)
            
            ScrollView {
                VStack {
                    Button {
                        viewModel.showSettings()
                    } label: {
                        HStack(spacing: 0) {
                            let screenWidth = UIScreen.main.bounds.width

                            SettingItemView(title: "Resolution", value: viewModel.settings.resolution)
                                .frame(width: screenWidth * 1.8/6.0)
                                                    
                            Spacer(minLength: 0)
    
                            SettingItemView(title: "Bitrate", value: viewModel.settings.bitrate)
                                .frame(width: screenWidth * 1.4/6.0)

                            Spacer(minLength: 0)
                            
                            SettingItemView(title: "Framerate", value: viewModel.settings.framerate)
                                .frame(width: screenWidth * 1.3/6.0)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 13)
                        .background(Color.white)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )
                        .shadow(color: .gray.opacity(0.18), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 20)
                    
                    VStack(spacing: 0) {
                        ZStack {
                            Image("equalizer")
                                .resizable()
                                .scaledToFit()
                        }
                        .padding(.top, 15)
                        
                        Text(viewModel.formatTime(viewModel.recordingTime))
                            .font(.adaptiveFont(size: 30, fontName: "PlusJakartaSans-Regular_Bold"))
                            .foregroundColor(.white.opacity(viewModel.isRecording ? 1 : 0.67))
                            .padding(.top, -22)
                        
                        Button {
                            viewModel.toggleRecording()
                        } label: {
                            Text(viewModel.isRecording ? "Stop screen recording" : "Start screen recording")
                                .font(.adaptiveFont(size: 18, fontName: "PlusJakartaSans-Regular_ExtraBold"))
                                .foregroundColor(Color(hex: "#FF294E"))
                                .padding(.vertical, 19)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(19)
                                .shadow(color: .gray.opacity(0.18), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 30)
                        }
                        .padding(.top, 15)
                        .padding(.bottom, 28)
                    }
                    .background(
                        Image("background")
                            .resizable()
                            .clipShape(
                                RoundedRectangle(cornerRadius: 27.0)
                            )
                            .shadow(color: Color(hex: "FF294E").opacity(0.18), radius: 7, x: 0, y: 4)
                    )
                    .onTapGesture {
                        viewModel.toggleRecording()
                    }
                    .padding(.top, 17)
                    
                    HStack(spacing: 18) {
                        // Face Reaction
                        FeatureOptionView(
                            image: "faceReaction",
                            title: "Face Reaction",
                            description: "Record reactions to your recording",
                            action: {
                                viewModel.openFaceReactionSettings()
                            }
                        )
                        
                        // Voice comment
                        FeatureOptionView(
                            image: "voiceComment",
                            title: "Voice comment",
                            description: "Record audio only commentary",
                            action: {
                                viewModel.openVoiceCommentSettings()
                            }
                        )
                    }
                    .padding(.top, 17)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 150)
            }
        }
        .sheet(isPresented: $viewModel.showingSettings) {
            SettingsSheetWrapper(
                settings: $viewModel.settings,
                onSettingsUpdated: { newSettings in
                    viewModel.updateSettings(newSettings: newSettings)
                }
            )
        }
    }
}

struct RecordingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        return Assembly.shared.makeRecordingScreen()
    }
}
