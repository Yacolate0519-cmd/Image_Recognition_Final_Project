import os
import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.transforms as transforms
import torchvision.models as models
from PIL import Image, ImageOps  # 👈 新增 ImageOps 用來處理旋轉
from flask import Flask, request, jsonify

# 新增：Segmentation 需要的函式庫
import cv2
import numpy as np
import base64
from ultralytics import YOLO
import datetime # 用來產生檔名

app = Flask(__name__)

# --- 設定路徑 ---
# CLS_MODEL_PATH = "models/model_v2.pth"
CLS_MODEL_PATH = "models/Model_1222.pth"
# SEG_MODEL_PATH = "models/seg.pt"
SEG_MODEL_PATH = "models/yolo11n-seg.pt"
UPLOAD_FOLDER = "uploads"
DEBUG_FOLDER = "debug_images"  # 👈 新增除錯資料夾，讓我們看看 Server 到底收到了什麼鬼
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
if not os.path.exists(DEBUG_FOLDER):
    os.makedirs(DEBUG_FOLDER)

# --- 類別定義 (保持不變) ---
CLASSES = [
    '何首烏', '山藥', '川芎', '木香', '熟地', 
    '甘草', '白朮片', '白芷', '紅耆', '羊奶頭', 
    '茯苓', '莪朮', '蒼朮片', '陳皮', '黃耆'
]

LABEL_TO_KEY_MAP = {
    '何首烏': 'Fallopia multiflora',
    '山藥': 'Dioscorea polystachya Turcz',
    '川芎': 'Ligusticum chuanxiong Hort',
    '木香': 'Radix Aucklandiae',
    '熟地': 'Prepared Rehmannia Root',
    '甘草': 'Licorice',
    '白朮片': 'Baizhu Slices',
    '白芷': 'Dahurian Angelica',
    '紅耆': 'Hedysarum Root',
    '羊奶頭': 'Taiwan Ficus',
    '茯苓': 'Poria',
    '莪朮': 'Zedoary Rhizome',
    '蒼朮片': 'Atractylodes Rhizome',
    '陳皮': 'Citri Reticulatae Pericarpium',
    '黃耆': 'Astragalus membranaceus'
}


# --- 1. 載入 Classification 模型 ---
def load_classification_model():
    print("正在載入 Classification 模型 (EfficientNet)...")
    model = models.efficientnet_b2(weights=None)
    in_features = model.classifier[1].in_features
    
    model.classifier = nn.Sequential(
        nn.Dropout(p=0.5), 
        nn.Linear(in_features, len(CLASSES))
    )
    
    try:
        # 這裡加入 strict=False 可以避免一些微小的 key 不匹配問題，但不建議常駐
        checkpoint = torch.load(CLS_MODEL_PATH, map_location=DEVICE)
        
        if 'state_dict' in checkpoint:
            state_dict = checkpoint['state_dict']
        else:
            state_dict = checkpoint
            
        model.load_state_dict(state_dict)
        model.to(DEVICE)
        model.eval()
        print("✅ Classification 模型載入成功！")
        return model
    except Exception as e:
        print(f"❌ Classification 模型載入失敗 (嚴重): {e}")
        # 如果模型載入失敗，我們應該讓程式報錯，而不是繼續執行
        return None 

# --- 2. 載入 Segmentation 模型 ---
def load_segmentation_model():
    print(f"正在載入 Segmentation 模型 (YOLO): {SEG_MODEL_PATH}...")
    try:
        model = YOLO(SEG_MODEL_PATH)
        print("✅ Segmentation 模型載入成功！")
        return model
    except Exception as e:
        print(f"❌ Segmentation 模型載入失敗: {e}")
        return None

cls_model = load_classification_model()
seg_model = load_segmentation_model()

# --- 預處理 ---
# ⚠️ 重要確認：請確認這跟您「訓練時」使用的預處理一模一樣
preprocess = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    )
])

@app.route('/upload', methods=['POST'])
def predict_api():
    if 'file' not in request.files:
        return jsonify({'status': 'error', 'message': '未傳送檔案'}), 400
    
    file = request.files['file']
    mode = request.form.get('mode', 'Classification')
    
    try:
        # 1. 開啟圖片
        image = Image.open(file)
        
        # 🛠️ 修正點 1：自動修正 EXIF 旋轉 (iOS 照片必備)
        image = ImageOps.exif_transpose(image)
        
        # 確保轉為 RGB (去除 Alpha 通道)
        image = image.convert('RGB')

        # 🛠️ 修正點 2：儲存 Server 實際看到的圖片 (用來除錯)
        # 請去 debug_images 資料夾看，圖片是不是黑的？是不是轉向了？
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        debug_path = os.path.join(DEBUG_FOLDER, f"{timestamp}_{mode}.jpg")
        image.save(debug_path)
        print(f"📸 已儲存除錯圖片: {debug_path}")

        # --- 分支 1: Classification ---
        if mode == 'Classification':
            if cls_model is None: return jsonify({'status': 'error', 'message': '模型未載入'}), 500

            input_tensor = preprocess(image).unsqueeze(0).to(DEVICE)

            with torch.no_grad():
                output = cls_model(input_tensor)        
                probs = F.softmax(output, dim=1)
                
                # 🛠️ 修正點 3：印出前三名，觀察是不是「甘草」機率只贏一點點
                # top3_prob, top3_class = probs.topk(3, dim=1)
                # print(f"🔍 Top 3 預測:")
                # for i in range(3):
                #     idx = top3_class[0][i].item()
                #     prob = top3_prob[0][i].item()
                #     print(f"   {i+1}. {CLASSES[idx]} ({prob:.2%})")
                

                # 取第一名回傳
                top_p, top_class = probs.topk(1, dim=1)
                class_index = top_class.item()
                confidence = top_p.item()
                
                chinese_label = CLASSES[class_index]
                app_herb_id = LABEL_TO_KEY_MAP.get(chinese_label, "Unknown")

            return jsonify({
                'status': 'success',
                'result': {
                    'herb_id': app_herb_id,    
                    'confidence': confidence
                }
            })

        # --- 分支 2: Segmentation ---
        elif mode == 'Segmentation':
            if seg_model is None: return jsonify({'status': 'error', 'message': '模型未載入'}), 500

            # 🛠️ 修正點 4：降低信心門檻 (0.5 -> 0.25)
            # 手機拍攝環境較複雜，0.5 可能太嚴格
            results = seg_model.predict(source=image, conf=0.25)
            
            if len(results) == 0 or len(results[0].boxes) == 0:
                print("⚠️ 分割模式：未偵測到任何物件")
                # 就算沒抓到，也回傳原圖給使用者看，避免 App 轉圈圈
                annotated_frame = np.array(image) 
                # 注意：PIL 轉 numpy 是 RGB，OpenCV 編碼需要 BGR
                annotated_frame = cv2.cvtColor(annotated_frame, cv2.COLOR_RGB2BGR)
            else:
                result = results[0]
                print(f"✂️ 分割模式：偵測到 {len(result.boxes)} 個物件")
                annotated_frame = result.plot() # plot 回傳的是 BGR

            # 轉 Base64
            retval, buffer = cv2.imencode('.jpg', annotated_frame)
            if retval:
                base64_string = base64.b64encode(buffer).decode('utf-8')
                return jsonify({
                    'status': 'success',
                    'result': {
                        'segmentation_image_base64': base64_string
                    }
                })
            else:
                return jsonify({'status': 'error', 'message': '圖片編碼失敗'}), 500

    except Exception as e:
        print(f"❌ Server 錯誤: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5001, debug=False)