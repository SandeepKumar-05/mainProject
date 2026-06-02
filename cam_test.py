from ultralytics import YOLO
import cv2
from picamera2 import Picamera2
import numpy as np

# Load YOLOv8 model (.pt file)
model = YOLO("best (2).pt")   # change to your model path

# Initialize Pi Camera
picam2 = Picamera2()
picam2.configure(picam2.create_preview_configuration(main={"format": "RGB888", "size": (640, 480)}))
picam2.start()

print("Starting Object Detection... Press 'q' to exit")

while True:
    # Capture frame
    frame = picam2.capture_array()

    # Run YOLOv8 detection
    results = model(frame)

    # Plot results on frame
    annotated_frame = results[0].plot()

    # Show output
    cv2.imshow("YOLOv8 Detection", annotated_frame)

    # Exit on Q
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cv2.destroyAllWindows()
picam2.stop()