//
//  API.swift
//  HerbScholar_Test
//
//  Created by Yacolate on 2025/12/18.
//

import Foundation
import UIKit
import Combine

// MARK: - 資料模型

// 給 App 內部使用的辨識結果結構
struct ServerResult: Equatable {
    let herbId: String
    let confidence: Double
}

// 對應 Server JSON "result" 內部的欄位
struct ServerResultData: Decodable {
    let herbId: String?
    let confidence: Double?
    let segmentationImageBase64: String?
    
    enum CodingKeys: String, CodingKey {
        case herbId = "herb_id"
        case confidence
        case segmentationImageBase64 = "segmentation_image_base64"
    }
}

// 對應 Server JSON 最外層
struct APIResponse: Decodable {
    let status: String
    let result: ServerResultData?
    let message: String?
}

// MARK: - API 設定
struct APIConfig {
    // ⚠️ 請確認您的 Server IP
    static let baseUrl = "http://10.21.100.106:5001"
    static let uploadEndpoint = "/upload"
    
    static var fullUploadUrl: String {
        return baseUrl + uploadEndpoint
    }
}

// MARK: - ImageUploadManager
class ImageUploadManager: ObservableObject {
    
    @Published var uploadStatus: String = "準備中"
    
    // 頻道 1: Classification 用
    @Published var serverResult: ServerResult? = nil
    
    // 頻道 2: Segmentation 用
    @Published var segmentationResult: UIImage? = nil
    
    func uploadImage(_ image: UIImage, mode: String) {
        // 1. 重置所有狀態
        DispatchQueue.main.async {
            self.uploadStatus = "上傳中..."
            self.serverResult = nil
            self.segmentationResult = nil
        }
        
        guard let url = URL(string: APIConfig.fullUploadUrl) else {
            self.uploadStatus = "URL 設定錯誤"
            return
        }
        
        // 2. 建立 Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 3. 建立 Body
        var body = Data()
        
        // 加入 mode 參數
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"mode\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(mode)\r\n".data(using: .utf8)!)
        
        // 加入圖片資料
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // 4. 發送請求
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async { self.uploadStatus = "連線失敗: \(error.localizedDescription)" }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { self.uploadStatus = "無資料回傳" }
                return
            }
            
            // 5. 解析與分流
            do {
                let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                
                DispatchQueue.main.async {
                    if decodedResponse.status == "success", let resultData = decodedResponse.result {
                        
                        if mode == "Classification" {
                            // --- 分流 A: 辨識 ---
                            if let id = resultData.herbId, let conf = resultData.confidence {
                                print("API: 收到辨識 ID \(id)")
                                // 觸發 serverResult 更新 -> CameraView 監聽跳轉
                                self.serverResult = ServerResult(herbId: id, confidence: conf)
                                self.uploadStatus = "辨識完成"
                            }
                            
                        } else if mode == "Segmentation" {
                            // --- 分流 B: 分割 ---
                            if let base64String = resultData.segmentationImageBase64,
                               let imageData = Data(base64Encoded: base64String),
                               let uiImage = UIImage(data: imageData) {
                                print("API: 收到分割圖片")
                                // 觸發 segmentationResult 更新 -> CameraView 監聽跳轉
                                self.segmentationResult = uiImage
                                self.uploadStatus = "分割完成"
                            }
                        }
                    } else {
                        self.uploadStatus = "Server 錯誤: \(decodedResponse.message ?? "未知")"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.uploadStatus = "解析失敗"
                    print("JSON Error: \(error)")
                }
            }
        }.resume()
    }
}
