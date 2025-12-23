import os
import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision.transforms as transforms
import torchvision.models as models
from PIL import Image, ImageOps 
from flask import Flask, request, jsonify

# 新增：去背需要的函式庫
from rembg import remove 

# Segmentation 需要的函式庫
import cv2
import numpy as np
import base64
from ultralytics import YOLO
import datetime

app = Flask(__name__)

# --- 設定路徑 ---
CLS_MODEL_PATH = "models/Half Data.pth"  
SEG_MODEL_PATH = "models/yolo11n-seg.pt"

UPLOAD_FOLDER = "uploads"
DEBUG_FOLDER = "debug_images"
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
if not os.path.exists(DEBUG_FOLDER):
    os.makedirs(DEBUG_FOLDER)

# --- 1. 類別定義 ---
CLASSES = [
    '山藥', '川芎', '木香', '熟地', '甘草', 
    '白芷', '紅耆', '莪朮', '蒼朮', '陳皮', '黃耆'
]

LABEL_TO_KEY_MAP = {
    '山藥': 'Dioscorea polystachya Turcz',
    '川芎': 'Ligusticum chuanxiong Hort',
    '木香': 'Radix Aucklandiae',
    '熟地': 'Prepared Rehmannia Root',
    '甘草': 'Licorice',
    '白芷': 'Dahurian Angelica',
    '紅耆': 'Hedysarum Root',
    '莪朮': 'Zedoary Rhizome',
    '蒼朮': 'Atractylodes Rhizome',
    '陳皮': 'Citri Reticulatae Pericarpium',
    '黃耆': 'Astragalus membranaceus'
}

# --- 2. 載入 Classification 模型 ---
def load_classification_model():
    print("正在載入 Classification 模型 (EfficientNet-B2)...")
    try:
        weights = models.EfficientNet_B2_Weights.IMAGENET1K_V1
        model = models.efficientnet_b2(weights=weights)
    except:
        print("⚠️ 無法載入 ImageNet 預訓練權重，使用空架構")
        model = models.efficientnet_b2(weights=None)

    for param in model.parameters(): 
      param.requires_grad = False

    in_features = model.classifier[1].in_features
    model.classifier = nn.Sequential(
        nn.Dropout(p=0.5), 
        nn.Linear(in_features, len(CLASSES))
    )
    
    try:
        checkpoint = torch.load(CLS_MODEL_PATH, map_location=DEVICE)
        if 'state_dict' in checkpoint:
            state_dict = checkpoint['state_dict']
        else:
            state_dict = checkpoint
            
        model.load_state_dict(state_dict)
        model.to(DEVICE)
        model.eval()
        print(f"✅ Classification 模型載入成功！(類別數: {len(CLASSES)})")
        return model
    except Exception as e:
        print(f"❌ Classification 模型載入失敗: {e}")
        return None 

# --- 3. 載入 Segmentation 模型 ---
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
preprocess = transforms.Compose([
    transforms.Resize(256),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    )
])

# --- 切圖函式 (Grid Split) ---
# 這就是你說的「切割圖像」，保留下來並用於去背後的圖
def split_img(img, splits=4):
    result = []
    img_w, img_h = img.size
    
    step_w = int(img_w / splits)
    step_h = int(img_h / splits)

    for row in range(splits):
        for col in range(splits):
            left = col * step_w
            upper = row * step_h
            right = left + step_w
            lower = upper + step_h
            
            if col == splits - 1: right = img_w
            if row == splits - 1: lower = img_h

            box = (left, upper, right, lower)
            tile = img.crop(box)
            result.append(tile)
    return result

@app.route('/upload', methods=['POST'])
def predict_api():
    if 'file' not in request.files:
        return jsonify({'status': 'error', 'message': '未傳送檔案'}), 400
    
    file = request.files['file']
    mode = request.form.get('mode', 'Classification')
    
    try:
        # 1. 開啟圖片並初步處理
        image = Image.open(file)
        image = ImageOps.exif_transpose(image) # 自動轉正
        
        # 產生時間戳記 (Debug用)
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

        # --- 分支 1: Classification (去背 -> 填黑 -> 切圖 -> 投票) ---
        if mode == 'Classification':
            if cls_model is None: return jsonify({'status': 'error', 'message': '模型未載入'}), 500

            # === A. 去背並填補黑底 (你提供的新邏輯) ===
            print("⏳ 正在進行去背處理 (Rembg)...")
            
            # rembg.remove 輸入可以是 PIL Image，回傳也是 PIL Image (RGBA)
            no_bg_image = remove(image)
            
            # 將透明背景轉為純黑色 (避免 CNN 對透明度通道感到困惑)
            # 建立一張全黑的底圖
            final_image = Image.new("RGB", no_bg_image.size, (0, 0, 0))
            # 將去背圖貼上去，使用 Alpha 通道作為 Mask
            # split()[3] 是 Alpha channel
            if no_bg_image.mode == 'RGBA':
                final_image.paste(no_bg_image, mask=no_bg_image.split()[3])
            else:
                # 如果 rembg 回傳的不是 RGBA (罕見)，就直接用 RGB
                final_image = no_bg_image.convert('RGB')

            # 📸 儲存去背後的圖片供檢查
            debug_path = os.path.join(DEBUG_FOLDER, f"{timestamp}_nobg.jpg")
            final_image.save(debug_path)
            print(f"✅ 去背完成，已儲存除錯圖: {debug_path}")

            # === B. 切圖 (4x4 = 16張) ===
            # 使用去背後的 final_image 進行切割
            splits = 4
            tiles = split_img(final_image, splits=splits)
            
            # === C. 預測與投票 ===
            vote_box = {cls_name: 0.0 for cls_name in CLASSES}
            
            with torch.no_grad():
                for tile in tiles:
                    input_tensor = preprocess(tile).unsqueeze(0).to(DEVICE)
                    output = cls_model(input_tensor)
                    probs = F.softmax(output, dim=1)
                    
                    top_p, top_class = probs.topk(1, dim=1)
                    idx = top_class.item()
                    conf = top_p.item()
                    
                    # 累加信心度
                    predicted_label = CLASSES[idx]
                    vote_box[predicted_label] += conf

            # === D. 結算 ===
            sorted_votes = sorted(vote_box.items(), key=lambda item: item[1], reverse=True)
            winner_label = sorted_votes[0][0]
            total_score = sorted_votes[0][1]
            avg_confidence = total_score / (splits * splits)
            app_herb_id = LABEL_TO_KEY_MAP.get(winner_label, "Unknown")
            
            print(f"🏆 辨識結果: {winner_label} (總分: {total_score:.2f})")

            return jsonify({
                'status': 'success',
                'result': {
                    'herb_id': app_herb_id,    
                    'confidence': avg_confidence, 
                    'chinese_name': winner_label
                }
            })

        # --- 分支 2: Segmentation (YOLO) ---
        elif mode == 'Segmentation':
            if seg_model is None: return jsonify({'status': 'error', 'message': '模型未載入'}), 500
            
            # 確保傳入的是原始圖片 (RGB)
            seg_input = image.convert('RGB')
            
            results = seg_model.predict(source=seg_input, conf=0.25)
            
            if len(results) == 0 or len(results[0].boxes) == 0:
                annotated_frame = np.array(seg_input) 
                annotated_frame = cv2.cvtColor(annotated_frame, cv2.COLOR_RGB2BGR)
            else:
                result = results[0]
                annotated_frame = result.plot() # 這裡會畫出切割框和遮罩

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
    if cls_model is None:
        print("⚠️ 警告：Classification 模型未成功載入")
        
    app.run(host='0.0.0.0', port=5001, debug=False)