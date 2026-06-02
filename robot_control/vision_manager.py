"""
vision_manager.py
────────────────────────────────────────────────
YOLOv8 Coconut Detection and MJPEG Streaming.
Handles camera capture, inference using best.pt,
and drawing bounding boxes.
────────────────────────────────────────────────
"""

import cv2
from ultralytics import YOLO
import threading
import time
import logging
from picamera2 import Picamera2
import numpy as np

log = logging.getLogger("VisionManager")

class VisionManager:
    def __init__(self, model_path="best (2).pt"):
        import os
        cwd = os.getcwd()
        log.info(f"VisionManager initialized. CWD: {cwd}")
        
        # 1. Try absolute path search
        possible_paths = [
            model_path,                                 # Current Dir
            os.path.join("..", model_path),             # Parent Dir
            os.path.join(cwd, model_path),              # Absolute Current
            os.path.join(os.path.dirname(cwd), model_path), # Absolute Parent
            f"/home/group10/{model_path}",              # Common Pi Home (adjust if needed)
            f"/home/pi/{model_path}"                    # Default Pi Home
        ]
        
        found_path = None
        for p in possible_paths:
            if os.path.exists(p):
                found_path = p
                break
        
        if found_path:
            log.info(f"✅ Found model file at: {found_path}")
            model_path = found_path
        else:
            log.warning(f"⚠️ Could not find {model_path} in common locations.")
            # We'll still try to load it in case YOLO has its own search logic
            # but we've logged the failure.

        log.info(f"🚀 Loading YOLOv8 model from {model_path}...")
        try:
            self.model = YOLO(model_path)
            log.info("YOLO model loaded successfully.")
        except Exception as e:
            log.error(f"❌ Failed to load model from {model_path}: {e}")
            self.model = None

        try:
            self.picam2 = Picamera2()
            self.picam2.configure(self.picam2.create_preview_configuration(main={"format": "RGB888", "size": (640, 480)}))
            self.picam2.start()
            log.info("Picamera2 started successfully.")
        except Exception as e:
            log.error(f"❌ Failed to start Picamera2: {e}")
            self.picam2 = None

        self.lock = threading.Lock()
        self.output_frame = None
        self.detections = {"green": 0, "dry": 0, "tender": 0}
        
        # Class mapping (Update these based on your model's real class indices)
        # Assuming: 0: unripped -> green, 1: ripped -> dry, 2: tender -> tender
        self.class_map = {
            "unripped": "green",
            "ripped": "dry",
            "tender": "tender"
        }
        
        if self.model:
            self.thread = threading.Thread(target=self._run_inference, daemon=True)
            self.thread.start()

    def _run_inference(self):
        while True:
            if not self.picam2:
                log.warning("Picamera2 is not running. Retrying...")
                time.sleep(1)
                continue

            try:
                # Capture frame from Picamera2
                frame = self.picam2.capture_array()
            except Exception as e:
                log.error(f"Error capturing frame: {e}")
                time.sleep(1)
                continue

            # Convert RGB (from picam2) to BGR for OpenCV display/encoding later if needed.
            # However YOLO might expect RGB or BGR, we'll keep as BGR for standard cv2 operations
            # in get_video_stream.
            frame = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)

            if not self.model:
                # If no model, just show the raw frame
                annotated_frame = frame.copy()
                current_counts = {"green": 0, "dry": 0, "tender": 0}
            else:
                # Run YOLOv8 inference
                results = self.model(frame, verbose=False)
            
                # Local detection count for this frame
                current_counts = {"green": 0, "dry": 0, "tender": 0}
                
                # Process results
                annotated_frame = frame.copy()
                for r in results:
                    boxes = r.boxes
                    for box in boxes:
                        # Get class name
                        cls_id = int(box.cls[0])
                        orig_cls = self.model.names[cls_id]
                        mapped_cls = self.class_map.get(orig_cls, orig_cls)
                        
                        if mapped_cls in current_counts:
                            current_counts[mapped_cls] += 1
                        
                        # Get box coordinates
                        b = box.xyxy[0].cpu().numpy()
                        conf = float(box.conf[0])
                        
                        # Draw box
                        color = (0, 255, 0) if mapped_cls == "green" else (0, 165, 255) if mapped_cls == "dry" else (255, 0, 0)
                        cv2.rectangle(annotated_frame, (int(b[0]), int(b[1])), (int(b[2]), int(b[3])), color, 2)
                        cv2.putText(annotated_frame, f"{mapped_cls} {conf:.2f}", (int(b[0]), int(b[1]) - 10),
                                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
            
            # Add vision status text
            status_text = "VISION ACTIVE" if self.model else "VISION ERROR (NO MODEL)"
            status_color = (0, 255, 0) if self.model else (0, 0, 255)
            cv2.putText(annotated_frame, status_text, (10, 30), 
                        cv2.FONT_HERSHEY_SIMPLEX, 1, status_color, 2)

            with self.lock:
                self.output_frame = annotated_frame
                self.detections = current_counts

    def get_video_stream(self):
        # Create a blank waiting frame to prevent Flutter timeouts
        waiting_frame = np.zeros((480, 640, 3), dtype=np.uint8)
        cv2.putText(waiting_frame, "CAMERA STARTING...", (160, 240), 
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
        _, encoded_waiting = cv2.imencode(".jpg", waiting_frame)
        waiting_bytes = bytearray(encoded_waiting)

        while True:
            frame_to_encode = None
            with self.lock:
                if self.output_frame is not None:
                    frame_to_encode = self.output_frame.copy()
            
            if frame_to_encode is None:
                # Yield the waiting frame so the HTTP 200 response fires
                # and Flutter doesn't hit a 5-second timeout Exception.
                yield(b'--frame\r\n' b'Content-Type: image/jpeg\r\n\r\n' + 
                      waiting_bytes + b'\r\n')
                time.sleep(1.0)
                continue
                
            # Encode the real camera frame
            (flag, encoded_image) = cv2.imencode(".jpg", frame_to_encode)
            if not flag:
                continue
            
            yield(b'--frame\r\n' b'Content-Type: image/jpeg\r\n\r\n' + 
                  bytearray(encoded_image) + b'\r\n')
            time.sleep(0.03) # Cap stream at ~30fps avoiding network flood

    def get_detections(self):
        with self.lock:
            return self.detections.copy()

    def cleanup(self):
        if hasattr(self, 'picam2') and self.picam2:
            self.picam2.stop()
