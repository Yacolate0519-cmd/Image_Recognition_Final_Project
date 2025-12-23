//
//  CameraPreview.swift
//  HerbScholar_Test
//
//  Created by Yacolate on 2025/12/18.
//

import SwiftUI
import AVFoundation // 1. 確保匯入這個框架

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraService: CameraService

    func makeUIView(context: Context) -> UIView {
        // 使用 UIView() 即可，不需要在初始化時給定 UIScreen.main.bounds
        let view = UIView()
        view.backgroundColor = .black

        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraService.session)
        previewLayer.videoGravity = .resizeAspectFill
        
        // 將 Layer 加入視圖
        view.layer.addSublayer(previewLayer)
        
        // 儲存 reference 以便在 updateUIView 或 layoutSubviews 調整大小
        context.coordinator.previewLayer = previewLayer
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // 2. 在這裡動態調整 Layer 的大小，確保旋轉或縮放時畫面正確
        DispatchQueue.main.async {
            context.coordinator.previewLayer?.frame = uiView.bounds
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
