import SwiftUI
import AVKit

struct LoopingVideoPlayerView: UIViewRepresentable {
    let videoName: String
    
    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(videoName: videoName)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }
}

class LoopingPlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    
    init(videoName: String) {
        super.init(frame: .zero)
        
        // Search for common video extensions
        let extensions = ["mp4", "mov"]
        var videoUrl: URL?
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: videoName, withExtension: ext) {
                videoUrl = url
                break
            }
        }
        
        guard let url = videoUrl else {
            print("Video not found: \(videoName)")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLayer.player = queuePlayer
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        queuePlayer.isMuted = true
        queuePlayer.play()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
