import SwiftUI
import AVFoundation

// A wrapper for AVFoundation's camera capture in SwiftUI
struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let cameraVC = CameraViewController()
        return cameraVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// Camera Controller using AVFoundation
class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        captureSession.sessionPreset = .medium
        
        guard let frontCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: frontCamera) else {
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let videoPreviewLayer = videoPreviewLayer else { return }
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        captureSession.startRunning()
    }
}


