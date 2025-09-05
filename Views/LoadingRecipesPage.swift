//
//
//MUNCHABLEApp
//Created by نوف بخيت الغامدي on 05/01/1447 AH.



import SwiftUI
import AVKit
import AVFoundation

// MARK: - Video Background (Loop)
struct PlayerView1: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView1>) { }
    func makeUIView(context: Context) -> UIView { LoopingPlayerUIView1(frame: .zero) }
}

final class LoopingPlayerUIView1: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        guard let fileUrl = Bundle.main.url(forResource: "demoVideo2", withExtension: "mp4") else {
            print("Error: Video file not found.")
            return
        }
        
        let asset  = AVAsset(url: fileUrl)
        let item   = AVPlayerItem(asset: asset)
        let player = AVQueuePlayer()
        player.volume = 0
        
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        player.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

// MARK: - Loading Screen
struct LoadingRecipesPage: View {
    var selectedIngredients: [String]
    
    @State private var isLoading = false
    @State private var navigateToNextPage = false
    @State private var generatedRecipe: String? = nil
    @State private var generatedTitle: String?  = nil
    
    var body: some View {
        ZStack {
            PlayerView1()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                GeometryReader { proxy in
                    HStack(spacing: 14) {
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundColor(Color("green"))
                            .offset(y: isLoading ? -10 : 0)
                            .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.2), value: isLoading)
                        
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundColor(Color("green"))
                            .offset(y: isLoading ? 0 : -10)
                            .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.4), value: isLoading)
                        
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundColor(Color("green"))
                            .offset(y: isLoading ? -10 : 0)
                            .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.6), value: isLoading)
                    }
                    .frame(width: 60, height: 10)
                    .position(x: proxy.size.width / 2,
                              y: proxy.size.height * 0.46)
                    .onAppear {
                        isLoading = true
                        callGPT()
                    }
                }
                
                .padding(.bottom, 40)
            }
            
            NavigationLink(
                destination: RecipeFromAi(
                    recipeText: generatedRecipe ?? "",
                    title: generatedTitle ?? "",
                    selectedIngredients: selectedIngredients
                ),
                isActive: $navigateToNextPage
            ) { EmptyView() }
                .hidden()
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        
    }
    
    private func callGPT() {
        ChatGPTService().generateRecipe(from: selectedIngredients) { title, recipeText in
            DispatchQueue.main.async {
                if let recipe = recipeText, let title = title {
                    self.generatedRecipe = recipe
                    self.generatedTitle  = title
                    self.navigateToNextPage = true
                }
            }
        }
    }
}

#Preview {
    LoadingRecipesPage(selectedIngredients: ["دجاج", "ملح", "فلفل"])
}
