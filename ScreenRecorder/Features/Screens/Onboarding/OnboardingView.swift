import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel: OnboardingViewModel
    
    @State private var currentStep: Int = 0
    private let animDuration = 0.2
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if currentStep == 0 {
                    OnboardingContent(
                        titleText: NSLocalizedString("**Record** your screen with ease", comment: ""),
                        subTitleText: NSLocalizedString("Create, edit, and share videos with anyone using the best screen recorder available", comment: ""),
                        imageName: "onboarding1"
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeInOut(duration: animDuration).delay(animDuration)),
                        removal: .opacity.animation(.easeInOut(duration: animDuration))
                    ))
                } else if currentStep == 1 {
                    OnboardingContent(
                        titleText: NSLocalizedString("**Create** a Face Reaction", comment: ""),
                        subTitleText: NSLocalizedString("Record videos from your screen, webcam, or both", comment: ""),
                        imageName: "onboarding2"
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeInOut(duration: animDuration).delay(animDuration)),
                        removal: .opacity.animation(.easeInOut(duration: animDuration))
                    ))
                } else if currentStep == 2 {
                    OnboardingContent(
                        titleText: NSLocalizedString("**We care** about you", comment: ""),
                        subTitleText: NSLocalizedString("We do whatever possible to provide you with the best user experience", comment: ""),
                        imageName: "onboarding3"
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeInOut(duration: animDuration).delay(animDuration)),
                        removal: .opacity.animation(.easeInOut(duration: animDuration))
                    ))
                }  else if currentStep == 3 {
                    OnboardingContent(
                        titleText: NSLocalizedString("Record **voice** comment", comment: ""),
                        subTitleText: NSLocalizedString("Enhance your recording with voiceover", comment: ""),
                        imageName: "onboarding4"
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeInOut(duration: animDuration).delay(animDuration)),
                        removal: .opacity.animation(.easeInOut(duration: animDuration))
                    ))
                }
            }
            .animation(.easeInOut, value: currentStep)
            
            CustomButton(title: NSLocalizedString("Continue", comment: "")) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation {
                    if currentStep < 2 {
                        currentStep += 1
                        if currentStep == 2 {
                            viewModel.showRequestReview()
                        }
                    } else {
                        viewModel.endOnboarding()
                    }
                }
            }
            .frame(maxWidth: 500)
            .padding(.horizontal, 24)
            
            HStack {
                Spacer()
                Spacer()
                Spacer()
                Button(NSLocalizedString("Privacy", comment: "")) {
                    viewModel.onPrivacyPressed()
                }
                Spacer()   
                Spacer()
                Button(NSLocalizedString("Restore", comment: "")) {
                    viewModel.onRestorePressed()
                }
                Spacer()            
                Spacer()
                Button(NSLocalizedString("Terms", comment: "")) {
                    viewModel.onTermsPressed()
                }
                Spacer()
                Spacer()
                Spacer()
            }
            .font(.adaptiveFont(size: 14, fontName: "PlusJakartaSans-Regular_Medium"))
            .foregroundColor(Color(hex: "9C9C9C"))
            .frame(maxWidth: 500)
            .frame(minWidth: 0)
            .padding(.top, 18)
            .padding(.bottom, 10)
        }
        .background(Color.white)
    }
}

struct OnboardingContent: View {
    let titleText: String
    let subTitleText: String
    let imageName: String
    
    var body: some View {
        VStack(spacing: 0) {
            let screenWidth = UIScreen.main.bounds.width
            let topPadding: CGFloat = screenWidth <= 380 ? 25 : 59
            
            titleText
                .formattedTextGradient(font: .adaptiveFont(size: 30, fontName: "PlusJakartaSans-Regular_ExtraBold"))
                .padding(.bottom, 20)
                .padding(.top, topPadding)
                .multilineTextAlignment(.center)
            
            Text(subTitleText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .font(.adaptiveFont(size: 16, fontName: "PlusJakartaSans-Regular_Medium"))
                .foregroundColor(Color(hex: "9C9C9C"))
                .padding(.bottom, 10)
                .padding(.horizontal, 15)
            
            Spacer()
            
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 600)
                .frame(minWidth: 0)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(viewModel: OnboardingViewModel(router: Router()))
    }
}
