import cv2
import numpy as np
import os
import imagehash
from PIL import Image  # Import the Image module from the PIL library
from keras.applications import MobileNetV2
from keras.layers import AveragePooling2D , Dropout , Flatten , Dense , Input ,LSTM
from keras.models import Model
from keras.optimizers import Adam
import torch.optim as optim
import mediapipe as mp
import tensorflow as tf
from keras import layers, models
import numpy as np
from sklearn.model_selection import train_test_split
import torch
import numpy as np
from keras_preprocessing.image import load_img, img_to_array
# from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelBinarizer
from imutils import paths



mp_holistic = mp.solutions.holistic
holistic = mp_holistic.Holistic(
    min_detection_confidence=0.5,  # Minimum confidence threshold for detection
    min_tracking_confidence=0.5    # Minimum confidence threshold for tracking
)


def process(path,out):
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

        pil_image = Image.fromarray(gray_frame)
        
        # Calculate hash for the current frame
        curr_hash = imagehash.average_hash(pil_image)
        # Compare with previous hash and skip if too similar
            

        # Convert BGR to RGB
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        # Process the frame with MediaPipe Holistic
        results = holistic.process(rgb_frame)

        black_bg = np.zeros_like(frame)

        if  results.right_hand_landmarks:
            # Calculate bounding box around the right hand
            right_hand_landmarks = results.right_hand_landmarks.landmark
            right_hand_xmin = int(min(l.x * width for l in right_hand_landmarks)) - padding
            right_hand_ymin = int(min(l.y * height for l in right_hand_landmarks)) - padding
            right_hand_xmax = int(max(l.x * width for l in right_hand_landmarks)) + padding
            right_hand_ymax = int(max(l.y * height for l in right_hand_landmarks)) + padding
            right_hand_roi = frame[right_hand_ymin:right_hand_ymax, right_hand_xmin:right_hand_xmax].copy()
            #1920*1080
            
            black_bg[right_hand_ymin:right_hand_ymax, right_hand_xmin:right_hand_xmax] = right_hand_roi
        else:
            fallback_image_path = 'DataSet/right hand.jpg'  # Path to your fallback image
            fallback_image = cv2.imread(fallback_image_path)

            if fallback_image is not None:
                # Calculate the dimensions of the target area
                target_height = 100  # This should be 160
                target_width = 1009 - 840   # This should be 169

                # Correctly resize the fallback image to match the target area dimensions
                fallback_image_resized = cv2.resize(fallback_image, (target_width, target_height))
                #1920*1080
                
               # black_bg[right_hand_ymin:right_hand_ymax, right_hand_xmin:right_hand_xmax] = right_hand_roi

                # Place the resized fallback image into the specified area of black_bg
                #y             black_bg[934:1094, 840:1009] = fallback_image_resized

                black_bg[980:1080, 700:869] = fallback_image_resized
            
        if results.left_hand_landmarks  and results.face_landmarks:
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

            face_roi = frame[face_ymin:face_ymax, face_xmin:face_xmax].copy()
            left_hand_roi = frame[left_hand_ymin:left_hand_ymax, left_hand_xmin:left_hand_xmax].copy()
            #gray_face = cv2.cvtColor(face_roi, cv2.COLOR_BGR2GRAY)
            gray_left_hand = cv2.cvtColor(left_hand_roi, cv2.COLOR_BGR2GRAY)
            #pil_face = Image.fromarray(gray_face)
            pil_left_hand = Image.fromarray(gray_left_hand)
            #face_hash = imagehash.average_hash(pil_face)
            left_hand_hash = imagehash.average_hash(pil_left_hand)
            
            if prev_left_hand_hash is not None and abs(left_hand_hash - prev_left_hand_hash) < 15:
                continue
            prev_left_hand_hash = left_hand_hash
            black_bg[face_ymin:face_ymax, face_xmin:face_xmax] = face_roi
            black_bg[left_hand_ymin:left_hand_ymax, left_hand_xmin:left_hand_xmax] = left_hand_roi
            black_bg = cv2.resize(black_bg,(224,224))

            frames.append(black_bg)
            frame_number += 1


    return frames
def downsample_frames(frames, target_frames=30, output_folder=None):
    total_frames = len(frames)
    
    frame_indices = [int(i * total_frames / float(target_frames)) for i in range(target_frames)]
    print("Target frames:", target_frames)  # Add this line to check the target number of frames
    print("Frame indices:", frame_indices)  # Add this line to check the calculated frame indices
    

    downsampled_frames = [frames[i] for i in frame_indices]
    if output_folder:
        os.makedirs(output_folder, exist_ok=True)
        for idx, frame in enumerate(downsampled_frames):
            cv2.imwrite(os.path.join(output_folder, f"{idx}.jpg"), frame)

    return downsampled_frames


# Define the input and output folders
input_root_folder = "DataSet/train"
output_root_folder = "4-train_frames"

# Ensure output directories exist
os.makedirs(output_root_folder, exist_ok=True)

dic = {}
dic_label={}
frames_by_class = {}

#Process each folder containing videos

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
                class_label = int(video_name.split('_')[1])  # Extract class label from video name
                # Process the video (You should define your process function)
                frames = process(video_path,output_folder)  # Assuming process() returns a list of frames
                
                # Create output folder for the current video
                video_output_folder = os.path.join(output_folder, video_name)
                os.makedirs(video_output_folder, exist_ok=True)

                # Downsample and save frames in the output folder for the current video
                downsampled_frames = downsample_frames(frames, 30, output_folder=video_output_folder)
                dic[video_name] = downsampled_frames
                if class_label not in frames_by_class:
                    frames_by_class[class_label] = []
                frames_by_class[class_label].extend(downsampled_frames)

    dic_label[folder_name]=dic

# Define the input and output folders
input_root_folder = "DataSet/test"
output_root_folder = "4-test_frames"

# Ensure output directories exist
os.makedirs(output_root_folder, exist_ok=True)

dic = {}
dic_label={}
frames_by_class = {}

#Process each folder containing videos

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
                class_label = int(video_name.split('_')[1])  # Extract class label from video name
                # Process the video (You should define your process function)
                frames = process(video_path,output_folder)  # Assuming process() returns a list of frames
                
                # Create output folder for the current video
                video_output_folder = os.path.join(output_folder, video_name)
                os.makedirs(video_output_folder, exist_ok=True)

                # Downsample and save frames in the output folder for the current video
                downsampled_frames = downsample_frames(frames, 30, output_folder=video_output_folder)
                dic[video_name] = downsampled_frames
                if class_label not in frames_by_class:
                    frames_by_class[class_label] = []
                frames_by_class[class_label].extend(downsampled_frames)

    dic_label[folder_name]=dic