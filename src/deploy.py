from PIL import Image
import torchvision.transforms as transforms
import torchvision.models as models
import torch
import torch.nn as nn
import torch.nn.functional as F

img_path = "images/甘草.png" 

classes = ['何首烏', '山藥', '川芎', '木香', '熟地', '甘草', '白朮片', '白芷', '紅耆', '羊奶頭', '茯苓', '莪朮', '蒼朮片', '陳皮', '黃耆']
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model_path = "models/model_v2.pth"

def load_model():
    model = models.efficientnet_b0(weights=models.EfficientNet_B0_Weights.IMAGENET1K_V1)
    in_features = model.classifier[1].in_features
    model.classifier = nn.Sequential(
        nn.Dropout(p=0.5), 
        nn.Linear(in_features, len(classes))
    )
    checkpoint = torch.load(model_path, map_location=device)
    if 'state_dict' in checkpoint:
        model.load_state_dict(checkpoint['state_dict'])
    else:
        model.load_state_dict(checkpoint)
    model = model.to(device)
    model.eval() 
    print("模型權重載入成功！")
    return model
    
preprocess = transforms.Compose([
    transforms.Resize(224),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    )
])

def predict_image(image_path, model):
    try:
        image = Image.open(image_path).convert('RGB')
    except:
        print("讀取圖片失敗")
        return

    # 預處理並增加 batch 維度 (C, H, W) -> (1, C, H, W)
    input_tensor = preprocess(image).unsqueeze(0).to(device)

    with torch.no_grad():
        output = model(input_tensor)        
        probs = F.softmax(output, dim=1)
        top_p, top_class = probs.topk(1, dim=1)
        class_index = top_class.item()
        confidence = top_p.item() * 100
    return class_index, confidence

if __name__ == "__main__":
    model = load_model()
    
    print(f"\n正在辨識圖片")
    
    index, conf = predict_image(img_path, model)
    
    predicted_label = classes[index]
    
    print(f"\n辨識完成!")
    print(f"預測類別 : {predicted_label}")
    print(f"信心度   : {conf:.2f}%")