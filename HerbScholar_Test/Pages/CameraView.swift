import SwiftUI

// 1. 資料庫查找工具
struct HerbDatabase {
    // 建立映射表：Server Key (英文) -> mockHerbs 裡的 ID
    static let keyToIdMap: [String: String] = [
        "Baizhu Slices": "1",                 // 白朮片
        "Atractylodes Rhizome": "2",          // 蒼朮
        "Radix Aucklandiae": "3",             // 木香
        "Prepared Rehmannia Root": "4",       // 熟地黃
        "Dioscorea polystachya Turcz": "5",   // 山藥
        "Dahurian Angelica": "6",             // 白芷
        "Citri Reticulatae Pericarpium": "7", // 陳皮
        "Fallopia multiflora": "8",           // 何首烏
        "Hedysarum Root": "9",                // 紅耆
        "Astragalus membranaceus": "10",      // 黃耆
        "Licorice": "11",                     // 甘草
        "Ligusticum chuanxiong Hort": "12",   // 川芎
        "Poria": "13",                        // 茯苓
        "Zedoary Rhizome": "14",              // 莪朮
        "Taiwan Ficus": "15"                  // 牛奶榕
    ]
    
    static func findHerb(byKey key: String) -> Herb? {
        guard let id = keyToIdMap[key] else { return nil }
        // 假設 mockHerbs 在全域變數中可存取
        return mockHerbs.first { $0.id == id }
    }
}

struct CameraView: View {
    
    @StateObject var cameraService = CameraService()
    @StateObject var uploadManager = ImageUploadManager()
    
    @State private var isScanning = false
    
    // MARK: - 導航狀態變數
    // Classification 用
    @State private var scannedHerb: Herb?
    @State private var navigateToResult = false
    
    // Segmentation 用
    @State private var segmentedImage: UIImage?
    @State private var navigateToSegmentation = false
    
    // Picker 變數
    @State private var selectionMode: String = "Classification"
    private var categories: [String] = ["Classification", "Segmentation"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. 底層：相機預覽
                CameraPreview(cameraService: cameraService)
                    .ignoresSafeArea()
                
                // 2. 上層：UI 介面
                VStack {
                    // Picker
                    Picker("模式選擇", selection: $selectionMode) {
                        ForEach(categories, id: \.self) { item in
                            Text(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // 掃描框
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.5), lineWidth: 4)
                            .frame(width: 300, height: 300)
                        
                        VStack {
                            HStack { CornerView(rotation: 0); Spacer(); CornerView(rotation: 90) }
                            Spacer()
                            HStack { CornerView(rotation: -90); Spacer(); CornerView(rotation: 180) }
                        }
                        .frame(width: 310, height: 310)
                        
                        if isScanning {
                            ScanningLine().frame(width: 290, height: 290)
                        }
                    }
                    
                    Text(isScanning ? uploadManager.uploadStatus : "將中藥放置方匡內")
                        .font(.system(size: 30))
                        .bold()
                        .foregroundColor(.white).shadow(radius: 2)
                        .padding(.top, 32)
                    
                    Spacer()
                    
                    // 拍照按鈕
                    Button(action: startScan) {
                        ZStack {
                            Circle().fill(isScanning ? Color.gray : Color.blue).frame(width: 130, height: 150).shadow(radius: 4)
                            if isScanning {
                                ProgressView().tint(.white).scaleEffect(1.5)
                            } else {
                                Image(systemName: "camera.fill").font(.system(size: 50)).foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(isScanning)
                    .padding(.bottom, 48)
                }
            }
            // MARK: - 導航邏輯 (重點)
            
            // 1. Classification 跳轉 -> 藥材詳細頁 (ResultView)
            .navigationDestination(isPresented: $navigateToResult) {
                if let herb = scannedHerb {
                    ResultView(herb: herb)
                }
            }
            
            // 2. Segmentation 跳轉 -> 圖片展示頁 (SegmentationResultView)
            .navigationDestination(isPresented: $navigateToSegmentation) {
                if let image = segmentedImage {
                    SegmentationResultView(resultImage: image)
                }
            }
            
            .onAppear {
                cameraService.checkPermissions()
                cameraService.onImageCaptured = { uiImage in
                    print("開始上傳，模式: \(selectionMode)")
                    uploadManager.uploadImage(uiImage, mode: selectionMode)
                }
            }
            
            // 監聽 Classification 結果
            .onChange(of: uploadManager.serverResult) { newResult in
                if selectionMode == "Classification", let result = newResult {
                    print("收到辨識結果，準備跳轉...")
                    if let foundHerb = HerbDatabase.findHerb(byKey: result.herbId) {
                        self.scannedHerb = foundHerb
                        self.isScanning = false
                        self.navigateToResult = true // 觸發跳轉
                    } else {
                        self.uploadManager.uploadStatus = "資料庫無此藥材"
                        self.isScanning = false
                    }
                }
            }
            
            // 監聽 Segmentation 結果
            .onChange(of: uploadManager.segmentationResult) { newImage in
                if selectionMode == "Segmentation", let image = newImage {
                    print("收到分割圖片，準備跳轉...")
                    self.segmentedImage = image
                    self.isScanning = false
                    self.navigateToSegmentation = true // 觸發跳轉
                }
            }
            
            // 錯誤處理
            .onChange(of: uploadManager.uploadStatus) { status in
                if status.contains("失敗") || status.contains("錯誤") {
                    self.isScanning = false
                }
            }
        }
    }
    
    func startScan() {
        isScanning = true
        // 拍照前清除舊資料，防止重複跳轉
        uploadManager.serverResult = nil
        uploadManager.segmentationResult = nil
        cameraService.takePhoto()
    }
}

// (CornerView, ScanningLine 等元件保持不變)

// MARK: - Components (保持不變)
struct CornerView: View {
    let rotation: Double
    var body: some View {
        Image(systemName: "arrow.up.left")
            .resizable()
            .frame(width: 30, height: 30)
            .foregroundColor(.blue)
            .rotationEffect(.degrees(rotation))
            .opacity(0)
            .overlay(
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 30))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 30, y: 0))
                }
                .stroke(Color.blue, lineWidth: 4)
                .rotationEffect(.degrees(rotation))
            )
    }
}

struct ScanningLine: View {
    @State private var offset: CGFloat = -150
    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(height: 2)
            .shadow(color: .blue, radius: 4)
            .offset(y: offset)
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                    offset = 150
                }
            }
    }
}

struct GuideStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay(
                    Text("\(number)")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                )
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    CameraView()
}
