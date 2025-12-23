# HerbScholar - Chinese Herb Recognition System

HerbScholar is a complete client-server application designed to identify and segment Chinese herbs from images. It consists of a robust Python backend leveraging deep learning models (EfficientNet & YOLO) and a user-friendly iOS frontend built with SwiftUI.

## 🌟 Features

-   **Herb Classification:** Identifies 15 different types of Chinese herbs using an EfficientNet-B2 model.
-   **Image Segmentation:** Detects and segments herbs within an image using YOLOv11.
-   **Real-time Processing:** Captures images via the iOS camera and processes them instantly on the local server.
-   **Debug Mode:** Saves processed images on the server for analysis and model improvement.

## 🏗 System Architecture

The project follows a classic Client-Server architecture:

-   **Server (Python/Flask):**
    -   Host: `0.0.0.0`
    -   Port: `5001`
    -   **Endpoints:** `/upload` (Handles both classification and segmentation requests).
    -   **Models:**
        -   `models/Model_1222.pth`: EfficientNet-B2 for classification.
        -   `models/yolo11n-seg.pt`: YOLOv11 for object segmentation.

-   **Client (iOS/SwiftUI):**
    -   Communicates with the server via HTTP POST requests.
    -   Handles image compression and results display.

## 🛠 Prerequisites

### Backend
-   Python 3.8+
-   CUDA-compatible GPU (Optional, but recommended for faster inference)

### Frontend
-   Mac with macOS
-   Xcode 14+
-   iOS Device or Simulator (iOS 15+)

## 🚀 Setup Instructions

### 1. Backend Setup (Python)

1.  **Clone the repository** (if you haven't already).

2.  **Install dependencies:**
    It is recommended to use a virtual environment.
    ```bash
    pip install -r requirements.txt
    ```

3.  **Run the Server:**
    ```bash
    python main.py
    ```
    You should see output indicating the server is running on `http://0.0.0.0:5001`.

    *Note: The server will automatically create `uploads/` and `debug_images/` directories.*

### 2. Frontend Setup (iOS)

1.  **Open the Project:**
    Open `HerbScholar_Test.xcodeproj` in Xcode.

2.  **Configure Server IP:**
    -   Navigate to `HerbScholar_Test/Model/Roboflow.swift`.
    -   Find the `APIConfig` struct.
    -   Update the `baseUrl` to match the local IP address of the machine running the Python server.
    
    ```swift
    struct APIConfig {
        // ⚠️ Change this to your computer's local IP address
        static let baseUrl = "http://YOUR_LOCAL_IP:5001" 
        static let uploadEndpoint = "/upload"
        // ...
    }
    ```

3.  **Build and Run:**
    -   Connect your iOS device or select a simulator.
    -   Press `Cmd + R` to build and run the app.

## 📱 Usage

1.  **Launch the App** on your iPhone.
2.  **Select a Mode** at the top (e.g., "Classification" or "Segmentation").
3.  **Take a Picture** of a Chinese herb.
4.  The app will upload the image to your Python server.
5.  **View Results:**
    -   **Classification:** Displays the herb name and confidence score.
    -   **Segmentation:** Displays the image with the herb outlined/masked.

## 📂 Project Structure

```
.
├── main.py                  # Entry point for the Flask backend server
├── requirements.txt         # Python dependencies
├── models/                  # Directory containing PyTorch and YOLO models
│   ├── Model_1222.pth       # Classification model
│   └── yolo11n-seg.pt       # Segmentation model
├── HerbScholar_Test/        # iOS App Source Code
│   ├── HerbScholar_TestApp.swift  # App entry point
│   ├── Pages/               # SwiftUI Views (Camera, Results, etc.)
│   └── Model/               # Data models & Networking (Roboflow.swift)
├── debug_images/            # (Generated) Stores processed images for debugging
└── uploads/                 # (Generated) Temporary storage for uploaded files
```

## 🧪 Development & Experimental Scripts

The repository includes several experimental scripts used during development:
-   `deploy.py`, `seg.py`: Early versions of the inference logic.
-   `crop_Image.py`: Server variant that applies a fixed crop before processing.
-   `fucker.py`: Advanced experimental server with background removal (`rembg`) and voting mechanisms.

## 📝 Supported Herbs

The system is trained to recognize the following classes:
-   何首烏 (Fallopia multiflora)
-   山藥 (Dioscorea polystachya)
-   川芎 (Ligusticum chuanxiong)
-   木香 (Radix Aucklandiae)
-   甘草 (Licorice)
-   ... and 10 others.