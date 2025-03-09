import SwiftUI

struct PaywallView: View {
    @StateObject var viewModel: PaywallViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    let screenWidth = UIScreen.main.bounds.width
                    let topPadding: CGFloat = screenWidth <= 380 ? 25 : 59
                    
                    viewModel.titleText
                        .formattedTextGradient(font: .adaptiveFont(size: 30, fontName: "PlusJakartaSans-Regular_ExtraBold"))
                        .padding(.bottom, 20)
                        .padding(.top, topPadding)
                        .multilineTextAlignment(.center)
                    
                    if viewModel.showNoInternetError {
                        Text(viewModel.subtitleText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .font(.adaptiveFont(size: 16, fontName: "PlusJakartaSans-Regular_Medium"))
                            .foregroundColor(Color(hex: "ff7581"))
                            .padding(.bottom, 10)
                            .padding(.horizontal, 15)
                    } else {
                        Text(viewModel.subtitleText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .font(.adaptiveFont(size: 16, fontName: "PlusJakartaSans-Regular_Medium"))
                            .foregroundColor(Color(hex: "9C9C9C"))
                            .padding(.bottom, 10)
                            .padding(.horizontal, 15)
                    }
                    
                    Spacer()
                    
                    Image(viewModel.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 600)
                        .frame(minWidth: 0)
                }
                
                if viewModel.showTabBar {
                    VStack(spacing: 0) {
                        Spacer() // This pushes the tab bar down
                        
                        CustomPicker(
                            selectedTab: Binding(
                                get: { self.viewModel.selectedTab },
                                set: { self.viewModel.onTabSelected(tab: $0) }
                            ),
                            tabs: viewModel.availableTabs
                        )
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            
            CustomButton(title: viewModel.continueButtonTitle) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation {
                    viewModel.onContinuePressed()
                }
            }
            .frame(maxWidth: 500)
            .padding(.horizontal, 24)
            .disabled(viewModel.showNoInternetError)
            
            HStack {
                Spacer()
                Button(NSLocalizedString("Privacy", comment: "")) {
                    viewModel.onPrivacyPressed()
                }
                Spacer()
                Button(NSLocalizedString("Restore", comment: "")) {
                    viewModel.onRestorePressed()
                }
                Spacer()
                Button(NSLocalizedString("Terms", comment: "")) {
                    viewModel.onTermsPressed()
                }
                Spacer()
                Button(NSLocalizedString("Not now", comment: "")) {
                    viewModel.onSkipPressed()
                }
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
        .onAppear {
            viewModel.loadProducts()
        }
    }
}

#Preview {
    PaywallView(viewModel: PaywallViewModel(router: Router()))
}
