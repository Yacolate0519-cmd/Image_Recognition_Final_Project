import os
import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.transforms as transforms
import torchvision.models as models
from PIL import Image, ImageOps
from flask import Flask, request, jsonify

# Segmentation 需要的函式庫
import cv2
import numpy as np
import base64
from ultralytics import YOLO
import datetime 

app = Flask(__name__)

# --- 設定路徑 ---
CLS_MODEL_PATH = "models/model_v3_aug.pth"
SEG_MODEL_PATH = "models/yolo11n-seg.pt"
UPLOAD_FOLDER = "uploads"
DEBUG_FOLDER = "debug_images"  
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
if not os.path.exists(DEBUG_FOLDER):
    os.makedirs(DEBUG_FOLDER)

# ==========================================
# 🎯 設定裁切範圍 (適用於 Classification 與 Segmentation)
# ==========================================
# 格式: (左上x, 左上y, 右下x, 右下y)
FIXED_CROP_BOX = (200, 500, 900, 1100)

# --- 類別定義 ---
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

# --- 載入模型 ---
def load_classification_model():
    print("正在載入 Classification 模型...")
    model = models.efficientnet_b0(weights=None)
    in_features = model.classifier[1].in_features
    model.classifier = nn.Sequential(nn.Dropout(p=0.5), nn.Linear(in_features, len(CLASSES)))
    try:
        checkpoint = torch.load(CLS_MODEL_PATH, map_location=DEVICE)
        state_dict = checkpoint['state_dict'] if 'state_dict' in checkpoint else checkpoint
        model.load_state_dict(state_dict)
        model.to(DEVICE)
        model.eval()
        print("✅ Classification 模型載入成功！")
        return model
    except Exception as e:
        print(f"❌ Classification 模型載入失敗: {e}")
        return None 

def load_segmentation_model():
    print(f"正在載入 Segmentation 模型...")
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
preprocess = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

@app.route('/upload', methods=['POST'])
def predict_api():
    if 'file' not in request.files:
        return jsonify({'status': 'error', 'message': '未傳送檔案'}), 400
    
    file = request.files['file']
    mode = request.form.get('mode', 'Classification')
    
    try:
        # 1. 開啟圖片並修正轉向
        image = Image.open(file)
        image = ImageOps.exif_transpose(image)
        image = image.convert('RGB')
        
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

        # ==========================================
        # ✂️ 全域裁切：所有模式都使用這張裁切後的圖
        # ==========================================
        print(f"✂️ 正在裁切圖片，範圍: {FIXED_CROP_BOX}")
        cropped_image = image.crop(FIXED_CROP_BOX)
        
        # 儲存裁切後的圖片 (請務必去資料夾檢查這張圖！)
        debug_path_crop = os.path.join(DEBUG_FOLDER, f"{timestamp}_{mode}_CROP.jpg")
        cropped_image.save(debug_path_crop)
        print(f"📸 已儲存裁切圖片: {debug_path_crop}")

        # --- 分支 1: Classification (使用裁切圖) ---
        if mode == 'Classification':
            if cls_model is None: return jsonify({'status': 'error', 'message': '模型未載入'}), 500

            # 使用「裁切後的圖片」進行預處理
            input_tensor = preprocess(cropped_image).unsqueeze(0).to(DEVICE)

            with torch.no_grad():
                output = cls_model(input_tensor)        
                probs = F.softmax(output, dim=1)
                top_p, top_class = probs.topk(1, dim=1)
                
                chinese_label = CLASSES[top_class.item()]
                app_herb_id = LABEL_TO_KEY_MAP.get(chinese_label, "Unknown")
                
                print(f"🔍 Classification 預測 (裁切後): {chinese_label} ({top_p.item():.2%})")

            return jsonify({
                'status': 'success',
                'result': {
                    'herb_id': app_herb_id,    
                    'confidence': top_p.item(),
                    'note': 'Prediction based on cropped area'
                }
            })

        # --- 分支 2: Segmentation (使用裁切圖) ---
        elif mode == 'Segmentation':
            if seg_model is None: return jsonify({'status': 'error', 'message': '模型未載入'}), 500

            # 使用「裁切後的圖片」丟給 YOLO
            results = seg_model.predict(source=cropped_image, conf=0.25)
            
            if len(results) == 0 or len(results[0].boxes) == 0:
                print("⚠️ 分割模式：裁切範圍內未偵測到物件")
                annotated_frame = np.array(cropped_image) 
                annotated_frame = cv2.cvtColor(annotated_frame, cv2.COLOR_RGB2BGR)
            else:
                result = results[0]
                print(f"✂️ 分割模式：在裁切範圍內偵測到 {len(result.boxes)} 個物件")
                annotated_frame = result.plot()

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