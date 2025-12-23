# HerbScholar - 中藥材識別系統

HerbScholar 是一個完整的客戶端-伺服器應用程式，旨在從圖像中識別和分割中藥材。它由一個利用深度學習模型（EfficientNet 和 YOLO）的強大 Python 後端和一個使用 SwiftUI 構建的用戶友善 iOS 前端組成。

## 🌟 功能特色

-   **中藥材分類：** 使用 EfficientNet-B2 模型識別 15 種不同的中藥材。
-   **圖像分割：** 使用 YOLOv11 檢測並分割圖像中的藥材。
-   **即時處理：** 透過 iOS 相機拍攝圖像，並在本地伺服器上即時處理。
-   **除錯模式：** 在伺服器上儲存處理過的圖像，用於分析和模型改進。

## 🏗 系統架構

本專案採用經典的客戶端-伺服器架構：

-   **伺服器端 (Python/Flask)：**
    -   主機：`0.0.0.0`
    -   埠號：`5001`
    -   **端點：** `/upload` (處理分類和分割請求)。
    -   **模型：**
        -   `models/Model_1222.pth`：用於分類的 EfficientNet-B2。
        -   `models/yolo11n-seg.pt`：用於物件分割的 YOLOv11。

-   **客戶端 (iOS/SwiftUI)：**
    -   透過 HTTP POST 請求與伺服器通訊。
    -   處理圖像壓縮和結果顯示。

## 🛠 前置需求

### 後端 (Backend)
-   Python 3.8+
-   相容 CUDA 的 GPU（可選，但建議使用以加快推論速度）

### 前端 (Frontend)
-   配備 macOS 的 Mac 電腦
-   Xcode 14+
-   iOS 設備或模擬器 (iOS 15+)

## 🚀 安裝說明

### 1. 後端設定 (Python)

1.  **複製儲存庫** (如果尚未複製)。

2.  **安裝依賴套件：**
    建議使用虛擬環境。
    ```bash
    pip install -r requirements.txt
    ```

3.  **執行伺服器：**
    ```bash
    python main.py
    ```
    您應該會看到輸出顯示伺服器正在 `http://0.0.0.0:5001` 上運行。

    *注意：伺服器將自動建立 `uploads/` 和 `debug_images/` 目錄。*

### 2. 前端設定 (iOS)

1.  **開啟專案：**
    在 Xcode 中開啟 `HerbScholar_Test.xcodeproj`。

2.  **設定伺服器 IP：**
    -   導航至 `HerbScholar_Test/Model/Roboflow.swift`。
    -   找到 `APIConfig` 結構。
    -   更新 `baseUrl` 以符合運行 Python 伺服器的機器的本地 IP 位址。
    
    ```swift
    struct APIConfig {
        // ⚠️ 將此更改為您電腦的本地 IP 位址
        static let baseUrl = "http://YOUR_LOCAL_IP:5001" 
        static let uploadEndpoint = "/upload"
        // ...
    }
    ```

3.  **建置並執行：**
    -   連接您的 iOS 設備或選擇模擬器。
    -   按下 `Cmd + R` 建置並執行應用程式。

## 📱 使用說明

1.  **啟動應用程式**：在您的 iPhone 上開啟。
2.  **選擇模式**：在頂部選擇模式（例如「分類」或「分割」）。
3.  **拍照**：拍攝中藥材的照片。
4.  應用程式將上傳圖像至您的 Python 伺服器。
5.  **查看結果：**
    -   **分類：** 顯示藥材名稱和信心分數。
    -   **分割：** 顯示帶有藥材輪廓/遮罩的圖像。

## 📂 專案結構

```
.
├── main.py                  # Flask 後端伺服器的進入點
├── requirements.txt         # Python 依賴套件列表
├── models/                  # 包含 PyTorch 和 YOLO 模型的目錄
│   ├── Model_1222.pth       # 分類模型
│   └── yolo11n-seg.pt       # 分割模型
├── HerbScholar_Test/        # iOS 應用程式原始碼
│   ├── HerbScholar_TestApp.swift  # 應用程式進入點
│   ├── Pages/               # SwiftUI 視圖 (相機、結果頁面等)
│   └── Model/               # 資料模型與網路連線 (Roboflow.swift)
├── debug_images/            # (自動生成) 儲存處理過的圖像用於除錯
└── uploads/                 # (自動生成) 上傳檔案的暫存區
```

## 🧪 開發與實驗腳本

儲存庫包含開發期間使用的幾個實驗腳本：
-   `deploy.py`, `seg.py`：推論邏輯的早期版本。
-   `crop_Image.py`：在處理前應用固定裁切的伺服器變體。
-   `fucker.py`：包含背景移除 (`rembg`) 和投票機制的進階實驗性伺服器。

## 📝 支援的中藥材

本系統經過訓練可識別以下類別：
-   何首烏 (Fallopia multiflora)
-   山藥 (Dioscorea polystachya)
-   川芎 (Ligusticum chuanxiong)
-   木香 (Radix Aucklandiae)
-   甘草 (Licorice)
-   ... 以及其他 10 種。

## 🚀 未來展望

-   **提升模型準確度：** 透過進一步的訓練和資料增強，持續改進分類和分割模型的準確度。
-   **擴充藥材資料庫：** 增加可識別的中藥材種類數量。
-   **用戶驗證：** 實作用戶登入和帳戶管理，以提供個人化體驗。
-   **歷史分析：** 允許用戶查看過去的掃描歷史和結果。
-   **多語言支援：** 提供多種語言的應用程式介面，以服務更廣泛的受眾。

## 📄 授權條款

本專案採用 MIT 授權條款 - 詳情請參閱 LICENSE.md 檔案。
