import cv2
import numpy as np
import mediapipe as mp
import os
import imagehash
from PIL import Image  # Import the Image module from the PIL library
from keras.applications import MobileNetV2
from keras.layers import AveragePooling2D , Dropout , Flatten , Dense , Input ,LSTM
from keras.models import Model
from keras.optimizers import Adam

# Initialize MediaPipe Holistic
mp_holistic = mp.solutions.holistic
holistic = mp_holistic.Holistic(
    min_detection_confidence=0.9,  # Minimum confidence threshold for detection
    min_tracking_confidence=0.2    # Minimum confidence threshold for tracking
)



def process(path):
# Define a VideoWriter to save the segmented video
    cap = cv2.VideoCapture(path)
# Padding for the bounding boxes
    padding = 20
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    frame_number = 1  # You can use the frame number or any other identifier here
    prev_face_hash = None
    prev_left_hand_hash = None
    prev_right_hand_hash = None
    prev_hash=None
    frames=[]
    while cap.isOpened():
        
        ret, frame = cap.read()
        if not ret:
            break
        gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Convert grayscale frame to Image object
        pil_image = Image.fromarray(gray_frame)
        
        # Calculate hash for the current frame
        curr_hash = imagehash.average_hash(pil_image)
        # Compare with previous hash and skip if too similar
            
        if prev_hash is not None and abs(curr_hash - prev_hash) <0:
            prev_hash = curr_hash

            continue

        # Convert BGR to RGB
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        # Process the frame with MediaPipe Holistic
        results = holistic.process(rgb_frame)

        # Check if hand and face landmarks are detected
        if results.left_hand_landmarks and results.right_hand_landmarks and results.face_landmarks:
            # Calculate bounding box around the face
            face_landmarks = results.face_landmarks.landmark
            face_xmin = int(min(l.x * width for l in face_landmarks)) - padding
            face_ymin = int(min(l.y * height for l in face_landmarks)) - padding
            face_xmax = int(max(l.x * width for l in face_landmarks)) + padding
            face_ymax = int(max(l.y * height for l in face_landmarks)) + padding

            # Calculate bounding box around the left hand
            left_hand_landmarks = results.left_hand_landmarks.landmark
            left_hand_xmin = int(min(l.x * width for l in left_hand_landmarks)) - padding
            left_hand_ymin = int(min(l.y * height for l in left_hand_landmarks)) - padding
            left_hand_xmax = int(max(l.x * width for l in left_hand_landmarks)) + padding
            left_hand_ymax = int(max(l.y * height for l in left_hand_landmarks)) + padding

            # Calculate bounding box around the right hand
            right_hand_landmarks = results.right_hand_landmarks.landmark
            right_hand_xmin = int(min(l.x * width for l in right_hand_landmarks)) - padding
            right_hand_ymin = int(min(l.y * height for l in right_hand_landmarks)) - padding
            right_hand_xmax = int(max(l.x * width for l in right_hand_landmarks)) + padding
            right_hand_ymax = int(max(l.y * height for l in right_hand_landmarks)) + padding

            # Extract isolated face and hands from the frame
            face_roi = frame[face_ymin:face_ymax, face_xmin:face_xmax].copy()
            left_hand_roi = frame[left_hand_ymin:left_hand_ymax, left_hand_xmin:left_hand_xmax].copy()
            right_hand_roi = frame[right_hand_ymin:right_hand_ymax, right_hand_xmin:right_hand_xmax].copy()

            # Convert isolated regions to grayscale
            gray_face = cv2.cvtColor(face_roi, cv2.COLOR_BGR2GRAY)
            gray_left_hand = cv2.cvtColor(left_hand_roi, cv2.COLOR_BGR2GRAY)
            gray_right_hand = cv2.cvtColor(right_hand_roi, cv2.COLOR_BGR2GRAY)

            # Convert grayscale images to PIL Image objects
            pil_face = Image.fromarray(gray_face)
            pil_left_hand = Image.fromarray(gray_left_hand)
            pil_right_hand = Image.fromarray(gray_right_hand)

            # Calculate hashes for the isolated regions
            face_hash = imagehash.average_hash(pil_face)
            left_hand_hash = imagehash.average_hash(pil_left_hand)
            right_hand_hash = imagehash.average_hash(pil_right_hand)

            # Compare hashes to determine similarity
            if prev_left_hand_hash is not None and abs(left_hand_hash - prev_left_hand_hash) < 15:
                continue
            # if prev_right_hand_hash is not None and abs(right_hand_hash - prev_right_hand_hash) < 10 and abs(right_hand_hash - prev_right_hand_hash)>1:
            #     continue

            # Update previous hashes
            prev_face_hash = face_hash
            prev_left_hand_hash = left_hand_hash
            prev_right_hand_hash = right_hand_hash

            # Save the isolated face and hands with black background
            black_bg = np.zeros_like(frame)
            black_bg[face_ymin:face_ymax, face_xmin:face_xmax] = face_roi
            black_bg[left_hand_ymin:left_hand_ymax, left_hand_xmin:left_hand_xmax] = left_hand_roi
            black_bg[right_hand_ymin:right_hand_ymax, right_hand_xmin:right_hand_xmax] = right_hand_roi

            # Save the isolated face and hands with black background
            #cv2.imwrite(os.path.join(output_dir, f"combined_{frame_number}.jpg"), black_bg)
            black_bg=cv2.resize(black_bg,(224,224))
            frames.append(black_bg)
            frame_number += 1
            prev_hash = curr_hash
    return frames

def downsample_frames(frames, target_frames=30, output_folder=None):
    total_frames = len(frames)
    frame_indices = [int(i * total_frames / target_frames) for i in range(target_frames)]
    downsampled_frames = [frames[i] for i in frame_indices]

    if output_folder:
        os.makedirs(output_folder, exist_ok=True)
        for idx, frame in enumerate(downsampled_frames):
            cv2.imwrite(os.path.join(output_folder, f"{idx}.jpg"), frame)

    return downsampled_frames

input_root_folder = "DataSet/train"
output_root_folder = "6-train_frames"

# Ensure output directories exist
os.makedirs(output_root_folder, exist_ok=True)

dic = {}
dic_label={}
# Process each folder containing videos
for folder_name in os.listdir(input_root_folder):
    folder_path = os.path.join(input_root_folder, folder_name)
    
    # Check if it's a directory
    if os.path.isdir(folder_path):
        # Create output folder for the current folder
        output_folder = os.path.join(output_root_folder, folder_name)
        os.makedirs(output_folder, exist_ok=True)
        
        # Process each video file in the current folder
        for video_file in os.listdir(folder_path):
            video_path = os.path.join(folder_path, video_file)
            
            # Check if it's a file and ends with .mp4
            if os.path.isfile(video_path) and video_file.endswith('.mp4'):
                video_name = os.path.splitext(video_file)[0]
                substring = video_name.split('_')[1]
                # Process the video (You should define your process function)
                frames = process(video_path)  # Assuming process() returns a list of frames
                
                # Create output folder for the current video
                video_output_folder = os.path.join(output_folder, video_name)
                os.makedirs(video_output_folder, exist_ok=True)

                # Downsample and save frames in the output folder for the current video
                downsampled_frames = downsample_frames(frames, 30, output_folder=video_output_folder)
                dic[video_name] = downsampled_frames


input_root_folder_test = "DataSet/test"  # Set your test data root folder path here
output_root_folder_test = "6-test_frames"  # Set the output root folder for processed frames

# Ensure output directories exist
os.makedirs(output_root_folder_test, exist_ok=True)

# Process each folder containing videos in the test data
for folder_name in os.listdir(input_root_folder_test):
    folder_path = os.path.join(input_root_folder_test, folder_name)
    
    # Check if it's a directory
    if os.path.isdir(folder_path):
        # Create output folder for the current folder in test data
        output_folder = os.path.join(output_root_folder_test, folder_name)
        os.makedirs(output_folder, exist_ok=True)
        
        # Process each video file in the current folder
        for video_file in os.listdir(folder_path):
            video_path = os.path.join(folder_path, video_file)
            
            # Check if it's a file and ends with .mp4
            if os.path.isfile(video_path) and video_file.endswith('.mp4'):
                video_name = os.path.splitext(video_file)[0]
                
                # Process the video (You should define your process function)
                frames = process(video_path)  # Assuming process() returns a list of frames
                
                # Create output folder for the current video
                video_output_folder = os.path.join(output_folder, video_name)
                os.makedirs(video_output_folder, exist_ok=True)

                # Downsample and save frames in the output folder for the current video
                downsampled_frames = downsample_frames(frames, 30, output_folder=video_output_folder)