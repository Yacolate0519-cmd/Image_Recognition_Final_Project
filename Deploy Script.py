from PIL import Image, ImageOps, ImageDraw, ImageFont
import torchvision.transforms as transforms
import torchvision.models as models
import torch
import torch.nn as nn
import torch.nn.functional as F
import os
import math

# --- 參數設定 ---
# 請替換成你要測試的圖片路徑
img_path = r"/Users/yacolate0519/Desktop/圖像識別期末專案/debug_images/IMG_1118.jpeg" 
model_path = r"/Users/yacolate0519/Desktop/圖像識別期末專案/models/Half Data.pth"

classes = ['山藥', '川芎', '木香', '熟地', '甘草', '白芷', '紅耆', '莪朮', '蒼朮', '陳皮', '黃耆']
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

def get_font(size=20):
    """自動尋找系統可用的中文字體"""
    mac_fonts = [
        "/System/Library/Fonts/STHeiti Light.ttc",
        "/System/Library/Fonts/PingFang.ttc",
        "/Library/Fonts/Arial Unicode.ttf"
    ]
    for font_path in mac_fonts:
        if os.path.exists(font_path):
            try: return ImageFont.truetype(font_path, size)
            except: continue
    print("⚠️ 警告：找不到中文字體")
    return ImageFont.load_default()

def add_frame_and_text(img, text, border_width=2, border_color='black', text_color='blue'):
    final_img = ImageOps.expand(img, border=border_width, fill=border_color)
    draw = ImageDraw.Draw(final_img)
    font = get_font(size=20) 
    w, h = final_img.size
    try:
        left, top, right, bottom = draw.textbbox((0, 0), text, font=font)
        text_w, text_h = right - left, bottom - top
    except AttributeError:
        text_w, text_h = draw.textsize(text, font=font)
    
    draw.text(((w - text_w) / 2, (h - text_h) / 2), text, font=font, fill=text_color, stroke_width=2, stroke_fill='white')
    return final_img

def display_image_list(images, cols=4):
    if not images: return
    w, h = images[0].size
    rows = math.ceil(len(images) / cols)
    grid = Image.new('RGB', (w * cols, h * rows), (255, 255, 255))
    for i, img in enumerate(images):
        grid.paste(img, ((i % cols) * w, (i // cols) * h))
    print("正在開啟圖片視窗...")
    grid.show()

def load_model():
    try:
        model = models.efficientnet_b2(weights=models.EfficientNet_B2_Weights.IMAGENET1K_V1)
    except:
        model = models.efficientnet_b2(weights=None)
    for param in model.parameters(): param.requires_grad = False
    model.classifier = nn.Sequential(nn.Dropout(p=0.5), nn.Linear(model.classifier[1].in_features, len(classes)))
    
    checkpoint = torch.load(model_path, map_location=device)
    state = checkpoint['state_dict'] if 'state_dict' in checkpoint else checkpoint
    model.load_state_dict(state)
    model.to(device).eval()
    print("模型權重載入成功！")
    return model

preprocess = transforms.Compose([
    transforms.Resize(256),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

def split_img(img_obj, splits):
    # 修改：移除了裁切特定區域的步驟，直接使用整張圖
    img = img_obj 
    
    result = []
    img_w, img_h = img.size
    step_w, step_h = int(img_w / splits), int(img_h / splits)
    
    for row in range(splits):
        for col in range(splits):
            left, upper = col * step_w, row * step_h
            right = left + step_w if col < splits - 1 else img_w
            lower = upper + step_h if row < splits - 1 else img_h
            result.append(img.crop((left, upper, right, lower)))
    return result

def predict_image(image, model):
    input_tensor = preprocess(image).unsqueeze(0).to(device)
    with torch.no_grad():
        output = model(input_tensor)
        probs = F.softmax(output, dim=1)
        top_p, top_class = probs.topk(1, dim=1)
    return top_class[0].item(), top_p[0].item() * 100

if __name__ == "__main__":
    if not os.path.exists(img_path) or not os.path.exists(model_path):
        print("❌ 找不到圖片或模型檔案")
    else:
        model = load_model()
        splits = 4 # 切成 4x4 = 16 張

        print(f"\n--- 開始處理流程 ---")
        
        # 1. 讀取原始圖片
        print(f"讀取圖片: {img_path}")
        original_img = Image.open(img_path)
        original_img = ImageOps.exif_transpose(original_img) # 修正方向

        # --- 2. 進行切塊 (全圖切割) ---
        print(f"\n正在進行全圖網格切割...")
        imgs = split_img(original_img, splits)
        
        if imgs:
            imgs_text = []
            vote_box = {c: 0.0 for c in classes}

            print(f"共有 {len(imgs)} 張小圖進行投票...\n")

            # --- 3. 逐張預測並累加分數 ---
            for i, img in enumerate(imgs):
                idx, conf = predict_image(img, model)
                label = classes[idx]
                vote_box[label] += conf
                
                display_text = f"{label}\n{int(conf)}%"
                imgs_text.append(add_frame_and_text(img, display_text))
            
            print("--- 切割圖辨識完成，開啟結果圖 ---")
            display_image_list(imgs_text, cols=splits)
            
            # --- 4. 結算總分 ---
            sorted_votes = sorted(vote_box.items(), key=lambda x: x[1], reverse=True)
            
            print("\n" + "="*30)
            print("📊 最終信心度統計 (總分排名)")
            print("="*30)
            
            for rank, (herb_name, total_score) in enumerate(sorted_votes[:3]):
                avg_score = total_score / (splits * splits)
                print(f"第 {rank+1} 名: 【{herb_name}】")
                print(f"   總累積信心度: {total_score:.2f}")
                print(f"   平均單張信心: {avg_score:.2f}%")
                print("-" * 20)
                
            winner = sorted_votes[0][0]
            print(f"\n🏆 判定結果: 這張圖片是 [{winner}]")
            print("="*30)
            
        else:
            print("❌ 圖片處理失敗")