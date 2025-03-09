import SwiftUI
import AVKit

struct VideoPreviewView: View {
    @StateObject var viewModel: VideoPreviewViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with filename and details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.videoFilename)
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text(viewModel.videoDurationAndSize)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 32, height: 32)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            // Video preview
            ZStack {
                if let player = viewModel.player {
                    VideoPlayer(player: player)
                        .aspectRatio(9/16, contentMode: .fit)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                } else {
                    Rectangle()
                        .foregroundColor(.black.opacity(0.1))
                        .aspectRatio(9/16, contentMode: .fit)
                        .cornerRadius(12)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        )
                }
            }
            .padding(.horizontal, 20)
            
            // Feature buttons grid
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    // Video Editor
                    FeatureButton(
                        icon: "pencil.circle.fill",
                        iconColor: Color(hex: "#FF6B6B"),
                        title: "Video Editor",
                        action: {
                            viewModel.openVideoEditor()
                        }
                    )
                    
                    // Share Recording
                    FeatureButton(
                        icon: "square.and.arrow.up.fill",
                        iconColor: Color(hex: "#FF9F43"),
                        title: "Share recording",
                        action: {
                            viewModel.shareRecording()
                        }
                    )
                }
                
                HStack(spacing: 16) {
                    // Face Reaction
                    FeatureButton(
                        icon: "face.smiling.fill",
                        iconColor: Color(hex: "#1DD1A1"),
                        title: "Face reaction",
                        action: {
                            viewModel.addFaceReaction()
                        }
                    )
                    
                    // Voice Comment
                    FeatureButton(
                        icon: "mic.fill",
                        iconColor: Color(hex: "#54A0FF"),
                        title: "Voice comment",
                        action: {
                            viewModel.addVoiceComment()
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            
            Spacer()
        }
        .onAppear {
            viewModel.preparePlayer()
        }
        .onDisappear {
            viewModel.stopPlayer()
        }
    }
}

struct FeatureButton: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 26))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}
