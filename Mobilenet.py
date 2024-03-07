import cv2
import numpy as np
import mediapipe as mp
import os
import imagehash
import pandas as pd
from PIL import Image  # Import the Image module from the PIL library
from keras.applications import MobileNetV2 , ResNet50
from keras.layers import AveragePooling2D , Dropout , Flatten , Dense , Input ,LSTM , TimeDistributed

from keras.models import Model
from keras.utils import to_categorical
from keras.optimizers import Adam
from keras.layers import Reshape
from keras.src.applications.convnext import preprocess_input
from keras_preprocessing.image import load_img, img_to_array
# from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelBinarizer
from imutils import paths
from sklearn.model_selection import train_test_split

Directory = r"Data_Set/Train"
Signers = ["1", "2", "4", "5", "6"]
Category = ["0001","0002","0003","0004","0005","0006","0007","0008","0009","0010"]
L = ["1","2","3","4","5","6","7","8","9","10"]



data = []
labels = []



# for idx, c in enumerate(Category):
#     path = os.path.join(Directory, c)
#     subdirectories = os.listdir(path)  # Get list of subdirectories (e.g., ["mohamed", "another_subdirectory"])

#     for subdirectory in subdirectories:
#         subdirectory_path = os.path.join(path, subdirectory)
#         image_files = os.listdir(subdirectory_path)  # Get list of image files in the subdirectory

#         file_data = []  # Array list to store images of each file

#         for img_file in image_files:
#             img_path = os.path.join(subdirectory_path, img_file)
#             image = load_img(img_path,
#                              target_size=(224, 224))  # Assuming the target size is (224, 224), adjust as necessary
#             image = img_to_array(image)
#             image = preprocess_input(image)

#             file_data.append(image)

#         data.append(file_data)  # Add the array list of images for the current file
#         labels.append(f"{L[idx]}")

for idx, signer in enumerate(Signers):
    signer_path = os.path.join(Directory, signer)
    sentences_folders = os.listdir(signer_path)  # Get list of sentence folders

    for sentence in Category:
        sentence_path = os.path.join(signer_path, sentence)
        videos_folders = os.listdir(sentence_path)  # Get list of video folders in the sentence folder

        for video_folder in videos_folders:
            video_folder_path = os.path.join(sentence_path, video_folder)
            frame_files = os.listdir(video_folder_path)  # Get list of image files in the video folder

            file_data = []  # List to store frames of each video

            for img_file in frame_files:
                img_path = os.path.join(video_folder_path, img_file)
                image = load_img(img_path, target_size=(224, 224))  # Assuming the target size is (224, 224)
                image = img_to_array(image)
                image = preprocess_input(image)

                file_data.append(image)

            data.append(file_data)  # Add the list of frames for the current video
            labels.append(f"{sentence}")



lb = LabelBinarizer()
labels = lb.fit_transform(labels)


data = np.array(data,dtype="float32")

labels = np.array(labels)


# Split data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(data, labels, test_size=0.2, random_state=42)


base_model = MobileNetV2(weights="imagenet",include_top=False,input_tensor=Input(shape=(224,224,3)))
base_model.layers.pop()

input_tensor = Input(shape=(30, 224, 224, 3))

# Apply TimeDistributed layer to the base model
time_distributed_layer = TimeDistributed(base_model)(input_tensor)

# Flatten the output of the base model
flatten_layer = TimeDistributed(Flatten())(time_distributed_layer)

# Apply LSTM layers
lstm_layer1 = LSTM(units=128, return_sequences=True)(flatten_layer)
lstm_layer2 = LSTM(units=64, return_sequences=False)(lstm_layer1)

# Add MLP layers
mlp_layer = Dense(64, activation='relu')(lstm_layer2)

# Output layer
output_layer = Dense(10, activation='softmax')(mlp_layer)

model = Model(inputs=input_tensor, outputs=output_layer)



for l in base_model.layers:
    l.trainable = False

opt = Adam(learning_rate=0.0001)
model.compile(loss="categorical_crossentropy" ,optimizer=opt,metrics=["accuracy"])

model.summary()

history = model.fit(X_train, y_train, batch_size=32, epochs=1, validation_data=(X_test, y_test))
model.predict(X_test)

Dir=r"Data_Set/Test"
test_data = []
test_labels = []
for idx, signer in enumerate(Signers):
    signer_path = os.path.join(Dir, signer)
    sentences_folders = os.listdir(signer_path)  # Get list of sentence folders

    for sentence in Category:
        sentence_path = os.path.join(signer_path, sentence)
        videos_folders = os.listdir(sentence_path)  # Get list of video folders in the sentence folder

        for video_folder in videos_folders:
            video_folder_path = os.path.join(sentence_path, video_folder)
            frame_files = os.listdir(video_folder_path)  # Get list of image files in the video folder

            file_data = []  # List to store frames of each video

            for img_file in frame_files:
                img_path = os.path.join(video_folder_path, img_file)
                image = load_img(img_path, target_size=(224, 224))  # Assuming the target size is (224, 224)
                image = img_to_array(image)
                image = preprocess_input(image)

                file_data.append(image)

            test_data.append(file_data)  # Add the list of frames for the current video
             # Add the array list of images for the current file


lb = LabelBinarizer()
test_data = np.array(test_data,dtype="float32")

prediction = model.predict(test_data)
predicted_labels_indices = np.argmax(prediction, axis=1)

predicted_labels = [Category[idx] for idx in predicted_labels_indices]
print(predicted_labels)

test_labels = to_categorical(predicted_labels, num_classes=len(Category))

excel_file_path = 'groundTruth.xlsx'

df = pd.read_excel(excel_file_path)

id_to_description = dict(zip(df['SentenceID'], df['Sentence']))
# print(id_to_description)
descriptions = [id_to_description.get(int(pid), 'ID not found') for pid in predicted_labels]
# Display the descriptions for each predicted label
for pid, description in zip(predicted_labels, descriptions):
    print(f'Description for ID {pid}: {description}')


# Evaluate the model on the test data
test_loss, test_accuracy = model.evaluate(test_data, test_labels, verbose=1)
print("Test Accuracy:", test_accuracy)