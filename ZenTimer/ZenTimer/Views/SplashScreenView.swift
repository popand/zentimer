import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            // Gradient background matching the app's theme
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 239/255, green: 68/255, blue: 68/255),
                    Color(red: 234/255, green: 88/255, blue: 12/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                // ZenTimer text
                Text("ZenTimer")
                    .font(.system(size: 48, weight: .ultraLight, design: .default))
                    .foregroundColor(.white)
                    .tracking(2)

                Spacer()
            }
        }
        .statusBar(hidden: true)
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}