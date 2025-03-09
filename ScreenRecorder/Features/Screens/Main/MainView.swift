import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .recording
    @StateObject var viewModel: MainViewModel
    
    let animationDuration = 0.2
    
    var body: some View {
        ZStack {
            ZStack {
                if selectedTab == .recording {
                    Assembly.shared.makeRecordingScreen()
                        .transition(.asymmetric(
                            insertion: .opacity.animation(.easeInOut(duration: animationDuration).delay(animationDuration)),
                            removal: .opacity.animation(.easeInOut(duration: animationDuration))
                        ))
                }
                
                if selectedTab == .history {
                    EmptyView()
                        .transition(.asymmetric(
                            insertion: .opacity.animation(.easeInOut(duration: animationDuration).delay(animationDuration)),
                            removal: .opacity.animation(.easeInOut(duration: animationDuration))
                        ))
                }
            }
            .animation(.easeInOut, value: selectedTab)
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.all)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    MainView(viewModel: MainViewModel())
}
