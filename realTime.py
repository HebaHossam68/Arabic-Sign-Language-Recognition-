import cv2
import numpy as np
import imagehash
from PIL import Image  # Import the Image module from the PIL library
from keras.applications import MobileNetV2
import mediapipe as mp
import numpy as np
import numpy as np
from keras.models import load_model
from keras.applications.mobilenet_v2 import preprocess_input
import os


mp_holistic = mp.solutions.holistic
holistic = mp_holistic.Holistic(
    min_detection_confidence=0.5,  # Minimum confidence threshold for detection
    min_tracking_confidence=0.5    # Minimum confidence threshold for tracking
)

#turn frame to horizontal shape
def add_black_bars(image_array):
    # The target resolution
    target_width = 1920
    target_height = 1080

    # Current image dimensions
    height, width = image_array.shape[:2]

    # Calculate the scaling factor and new dimensions
    scale = min(target_height / height, target_width / width)
    new_width = int(width * scale)
    new_height = int(height * scale)

    # Resize the image with the scaling factor
    resized_image = cv2.resize(image_array, (new_width, new_height), interpolation=cv2.INTER_AREA)

    # Calculate padding to add to reach target size
    top = (target_height - new_height) // 2
    bottom = target_height - new_height - top
    left = (target_width - new_width) // 2
    right = target_width - new_width - left

    # Add black bars
    new_image = cv2.copyMakeBorder(resized_image, top, bottom, left, right, cv2.BORDER_CONSTANT, value=[0, 0, 0])

    return new_image


def process(path):
    cap = cv2.VideoCapture(path)
    padding = 20
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    frame_number = 1
    prev_left_hand_hash = None
    frames = []

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        if width < height:
            frame = add_black_bars(frame)
        frame=cv2.resize(frame,(1920,1080))
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = holistic.process(rgb_frame)
        black_bg = np.zeros_like(frame)

        if results.right_hand_landmarks:
            right_hand_landmarks = results.right_hand_landmarks.landmark
            right_hand_xmin = int(min(l.x * width for l in right_hand_landmarks)) - padding
            right_hand_ymin = int(min(l.y * height for l in right_hand_landmarks)) - padding
            right_hand_xmax = int(max(l.x * width for l in right_hand_landmarks)) + padding
            right_hand_ymax = int(max(l.y * height for l in right_hand_landmarks)) + padding
            right_hand_roi = frame[right_hand_ymin:right_hand_ymax, right_hand_xmin:right_hand_xmax].copy()
            black_bg[right_hand_ymin:right_hand_ymax, right_hand_xmin:right_hand_xmax] = right_hand_roi
        else:
            fallback_image_path = 'right_hand.jpg'
            fallback_image = cv2.imread(fallback_image_path)

            if fallback_image is not None:
                fallback_image_resized = cv2.resize(fallback_image, (169, 100))
                black_bg[980:1080, 700:869] = fallback_image_resized

        if results.left_hand_landmarks and results.face_landmarks:
            face_landmarks = results.face_landmarks.landmark
            face_xmin = int(min(l.x * width for l in face_landmarks)) - padding
            face_ymin = int(min(l.y * height for l in face_landmarks)) - padding
            face_xmax = int(max(l.x * width for l in face_landmarks)) + padding
            face_ymax = int(max(l.y * height for l in face_landmarks)) + padding

            left_hand_landmarks = results.left_hand_landmarks.landmark
            left_hand_xmin = int(min(l.x * width for l in left_hand_landmarks)) - padding
            left_hand_ymin = int(min(l.y * height for l in left_hand_landmarks)) - padding
            left_hand_xmax = int(max(l.x * width for l in left_hand_landmarks)) + padding
            left_hand_ymax = int(max(l.y * height for l in left_hand_landmarks)) + padding

            face_roi = frame[face_ymin:face_ymax, face_xmin:face_xmax].copy()
            left_hand_roi = frame[left_hand_ymin:left_hand_ymax, left_hand_xmin:left_hand_xmax].copy()
            gray_left_hand = cv2.cvtColor(left_hand_roi, cv2.COLOR_BGR2GRAY)
            pil_left_hand = Image.fromarray(gray_left_hand)
            left_hand_hash = imagehash.average_hash(pil_left_hand)

            if prev_left_hand_hash is not None and abs(left_hand_hash - prev_left_hand_hash) < 15:
                continue
            prev_left_hand_hash = left_hand_hash
            black_bg[face_ymin:face_ymax, face_xmin:face_xmax] = face_roi
            black_bg[left_hand_ymin:left_hand_ymax, left_hand_xmin:left_hand_xmax] = left_hand_roi
            black_bg = cv2.resize(black_bg, (224, 224))

            frames.append(black_bg)
            frame_number += 1

    return frames

def downsample_frames(frames, target_frames=30, output_folder=None):
    total_frames = len(frames)
    print(total_frames)
    # Calculate frame indices for downsampling
    frame_indices = [int(i * total_frames / target_frames) for i in range(target_frames)]
    
    # Downsample frames based on calculated indices
    downsampled_frames = [frames[i] for i in frame_indices]
    
    # If output_folder is provided, save downsampled frames to disk
    if output_folder:
        os.makedirs(output_folder, exist_ok=True)
        for idx, frame in enumerate(downsampled_frames):
            cv2.imwrite(os.path.join(output_folder, f"{idx}.jpg"), frame)

    return downsampled_frames


# Define the input and output folders



from multiprocessing import Pool
import time

def process_video(video_path,output):
    frames = process(video_path)
    downsampled_frames = downsample_frames(frames,output_folder=output)
    return downsampled_frames

def main():
    video_path = "VID_20240406_055336(0).mp4"
    start_time = time.time()
    output_folder="output_images"
    # Process video
    frames = process_video(video_path,output_folder)

    model_path = "MobileNetV2.h5"

    # Load the model
    model = load_model(model_path)
    predictions = model.predict(np.expand_dims(frames, axis=0))  # Add batch dimension
    predicted_class_index = np.argmax(predictions)

    # Assuming you have a list of class labels
    class_labels = ["1", "2", "3","4","5","6","7","8","9","10"]  # Replace with your actual class labels

    # Get the predicted class label
    predicted_class_label = class_labels[predicted_class_index]

    # Print the predicted class label
    print("Predicted class label:", predicted_class_label)

    end_time = time.time()
    elapsed_time = end_time - start_time
    print("Total time taken:", elapsed_time, "seconds")

if __name__ == "__main__":
    main()
