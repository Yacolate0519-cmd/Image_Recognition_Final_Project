from ultralytics import YOLO
import cv2

def predict_image(model_path, image_path):

    print(f"正在載入模型：{model_path}...")
    model = YOLO(model_path)

    print(f"正在預測圖片：{image_path}...")
    results = model.predict(source=image_path, conf=0.5, save=True)

    for result in results:
        boxes = result.boxes
        print(f"偵測到 {len(boxes)} 個物件")
        
        res_plotted = result.plot()
        cv2.imshow("Result", res_plotted)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

if __name__ == "__main__":

    MODEL_FILE = "models/seg.pt"       
    IMAGE_FILE = "images/甘草.png"  

    predict_image(MODEL_FILE, IMAGE_FILE)