//
//  Make it .swift
//  MUNCHABLE
//
//  Created by نوف بخيت الغامدي on 29/03/1445 AH.

import SwiftUI
import AVKit
import AVFoundation

struct PlayerView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {}
    
    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(frame: .zero)
    }
}

class LoopingPlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        guard let fileUrl = Bundle.main.url(forResource: "demoVideo", withExtension: "mp4") else {
            print("Error: Video file not found!")
            return
        }
        
        let asset = AVAsset(url: fileUrl)
        let item = AVPlayerItem(asset: asset)
        
        let player = AVQueuePlayer()
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

struct Make_it_: View {
    var body: some View {
        NavigationStack {
            ZStack {
                PlayerView()
                    .edgesIgnoringSafeArea(.all)
                
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 18) {
                        Text(NSLocalizedString("welcome_message", comment: ""))
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                            .padding(.horizontal, 22)
                        
                        Group {
                            Text("Get ready to explore mouthwatering recipes and elevate your cooking skills with ")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(.white)
                            +
                            Text("Munchable!")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)
                        .shadow(color: .black.opacity(0.3), radius: 1)
                    }
                    .padding(.top, 20) 
                    
                    Spacer()
                    
                    NavigationLink(destination: CategorysPage()) {
                        Text(NSLocalizedString("start_button", comment: ""))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 281, height: 41)
                            .background(Color("green"))
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    Make_it_()
}
