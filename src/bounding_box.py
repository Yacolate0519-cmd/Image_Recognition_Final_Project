import cv2

# 1. 讀取圖片
image_path = 'debug_images/20251221_130308_Classification.jpg'  # 請換成你的圖片路徑
img = cv2.imread(image_path)

# 確保圖片讀取成功
if img is None:
    print("找不到圖片，請確認路徑")
else:
    # 2. 設定 Bounding Box 參數
    # 左上角座標 (x1, y1)
    start_point = (200, 500) 
    # 右下角座標 (x2, y2)
    end_point = (900, 1100)
    
    # 顏色 (B, G, R) 格式 -> (0, 255, 0) 是綠色
    color = (0, 255, 0)
    
    # 線條粗細 (px)
    thickness = 5

    # 3. 畫矩形
    # cv2.rectangle(影像, 左上座標, 右下座標, 顏色, 粗細)
    img_with_box = cv2.rectangle(img, start_point, end_point, color, thickness)

    # (可選) 加入文字標籤
    cv2.putText(img_with_box, "Target", (start_point[0], start_point[1]-10), 
                cv2.FONT_HERSHEY_SIMPLEX, 1.5, color, 3)

    # 4. 儲存或顯示結果
    cv2.imwrite('output_opencv.jpg', img_with_box)
    print("圖片已儲存為 output_opencv.jpg")
    
    # 若在伺服器環境 (如 Colab/Docker) 建議只用 imwrite，不要用 imshow
    # cv2.imshow('Result', img_with_box)
    # cv2.waitKey(0)
    # cv2.destroyAllWindows()