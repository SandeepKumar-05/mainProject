#!/usr/bin/env python3
"""
server.py  — CocoBot Robot Control Server
──────────────────────────────────────────
• WebSocket on port 8765  ← Flutter app connects here
• Flask MJPEG stream on port 8080  ← Flutter video feed

Run:  sudo python3 server.py
"""

import asyncio
import json
import logging
import sys
import os
import time
import threading
from datetime import datetime

import websockets
from flask import Flask, Response

import motor_controller as motor
from vision_manager import VisionManager

os.environ["ULTRALYTICS_UPDATE"] = "False"

# ── Logging ──────────────────────────────────────────
logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler("robot.log"),
    ]
)
log = logging.getLogger("CocoBot")

# ── Constants ─────────────────────────────────────────
HOST = "0.0.0.0"
WS_PORT = 8765
HTTP_PORT = 8080
TELEMETRY_INTERVAL = 2.0

# ── State ─────────────────────────────────────────────
connected_clients: set = set()
_battery = 87
_temp = 31.5
_coconuts = 0

# ── Vision ────────────────────────────────────────────
vision = VisionManager(model_path="best (2).pt")

# ── Flask (MJPEG video) ───────────────────────────────
flask_app = Flask(__name__)

@flask_app.route('/video_feed')
def video_feed():
    return Response(
        vision.get_video_stream(),
        mimetype='multipart/x-mixed-replace; boundary=frame'
    )

def run_flask():
    flask_app.run(host=HOST, port=HTTP_PORT, threaded=True, use_reloader=False)


# ══════════════════════════════════════════════════════
#   Command table  (string sent by Flutter → function)
# ══════════════════════════════════════════════════════
COMMANDS = {
    # Climbing / driving
    "FORWARD":        motor.forward,
    "BACKWARD":       motor.backward,
    "LEFT":           motor.turn_left,
    "RIGHT":          motor.turn_right,
    "STOP":           motor.stop,
    "EMERGENCY_STOP": motor.emergency_stop,

    # Harvesting arm (servo)
    "ARM_DEPLOY":     motor.arm_deploy,
    "RESET":          motor.arm_reset,
    "SERVO_LEFT":     motor.arm_left,
    "SERVO_CENTER":   motor.arm_center,
    "SERVO_RIGHT":    motor.arm_right,

    # Cutting motor
    "MOTOR_ON":       motor.harvesting_on,
    "MOTOR_OFF":      motor.harvesting_off,
}


# ══════════════════════════════════════════════════════
#   WebSocket command handler
# ══════════════════════════════════════════════════════
async def handle_command(raw: str, websocket):
    global _coconuts

    # Accept plain string OR JSON {"command": "..."}
    try:
        data = json.loads(raw)
        cmd = data.get("command", "").strip().upper()
    except (json.JSONDecodeError, AttributeError):
        cmd = raw.strip().upper()

    log.info("⬅  CMD: %s", cmd)

    action = COMMANDS.get(cmd)
    if action:
        try:
            action()
            if cmd == "HARVEST":
                _coconuts += 1
            await _send(websocket, {"type": "ack", "command": cmd, "success": True})
        except Exception as e:
            log.error("Error running %s: %s", cmd, e)
            await _send(websocket, {"type": "ack", "command": cmd, "success": False, "error": str(e)})
    else:
        log.warning("Unknown command: %s", cmd)
        await _send(websocket, {"type": "ack", "command": cmd, "success": False, "error": "Unknown command"})


# ══════════════════════════════════════════════════════
#   Telemetry broadcaster
# ══════════════════════════════════════════════════════
async def telemetry_broadcaster():
    while True:
        await asyncio.sleep(TELEMETRY_INTERVAL)
        if not connected_clients:
            continue

        detections = vision.get_detections()
        payload = {
            "type":              "telemetry",
            "connected":         True,
            "battery":           _battery,
            "temperature":       _temp,
            "coconuts_harvested": _coconuts,
            "detections":        detections,
            "altitude":          0.0,
            "timestamp":         datetime.utcnow().isoformat(),
        }

        dead = set()
        for ws in list(connected_clients):
            try:
                await ws.send(json.dumps(payload))
            except websockets.ConnectionClosed:
                dead.add(ws)
        connected_clients -= dead


# ══════════════════════════════════════════════════════
#   WebSocket connection handler
# ══════════════════════════════════════════════════════
async def on_connect(websocket, path=""):
    ip = websocket.remote_address[0]
    log.info("✅ Flutter connected from %s", ip)
    connected_clients.add(websocket)

    # Immediate telemetry snapshot so the app shows data right away
    await _send(websocket, {
        "type":        "telemetry",
        "connected":   True,
        "battery":     _battery,
        "temperature": _temp,
    })

    try:
        async for message in websocket:
            await handle_command(message, websocket)
    except (websockets.ConnectionClosedError, websockets.ConnectionClosedOK):
        log.info("🔌 Client %s disconnected", ip)
    finally:
        connected_clients.discard(websocket)


async def _send(ws, data: dict):
    try:
        await ws.send(json.dumps(data))
    except Exception:
        pass


# ══════════════════════════════════════════════════════
#   Main
# ══════════════════════════════════════════════════════
async def main():
    log.info("🤖 CocoBot Server starting...")
    log.info("   WebSocket : ws://%s:%d", HOST, WS_PORT)
    log.info("   Video feed: http://%s:%d/video_feed", HOST, HTTP_PORT)

    # Flask in background thread
    threading.Thread(target=run_flask, daemon=True).start()

    async with websockets.serve(on_connect, HOST, WS_PORT):
        asyncio.create_task(telemetry_broadcaster())
        await asyncio.Future()   # Run forever


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        log.info("🛑 Shutting down...")
        motor.cleanup()
