#runnig_______________________________Resnet__________________________________________running#
import cv2
import numpy as np
import os
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelBinarizer
from keras.applications import ResNet50
from keras.layers import Input, LSTM, TimeDistributed, Flatten, Dense
from keras.models import Model
from keras.optimizers import Adam
import matplotlib.pyplot as plt





def load_data(Signers,Directory,Category):

    data = []
    labels = []
    for idx, signer in enumerate(Signers):
        print(idx)
        signer_path = os.path.join(Directory, signer)
        sentences_folders = os.listdir(signer_path)  

        for sentence in Category:
            sentence_path = os.path.join(signer_path, sentence)
            videos_folders = os.listdir(sentence_path)  

            for video_folder in videos_folders:
                video_folder_path = os.path.join(sentence_path, video_folder)
                frame_files = os.listdir(video_folder_path)  

                file_data = []  

                for img_file in frame_files:
                    img_path = os.path.join(video_folder_path, img_file)
                    image = cv2.imread(img_path)

                    file_data.append(image)

                data.append(file_data)  
                labels.append(f"{sentence}")
    return np.array(data, dtype="float32"), np.array(labels)

Signers = ["1","2"]
Category = ["0001","0002","0003","0004",
          "0005","0006","0007",
            "0008","0009","0010",
            "0011","0012","0013","0014","0015","0016","0017","0018","0019","0020",
            "0021","0022","0023","0024","0025","0026","0027","0028","0029","0030",
            "0031","0032","0033","0034","0035","0036","0037","0038","0039","0040",
            "0041","0042","0043","0044","0045","0046","0047","0048","0049","0050"
           ]
L = ["1","2","3","4"
 ,"5","6","7"
     ,"8","9","10"
    ,"11","12","13","14","15","16","17","18"
     ,"19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34"
     ,"35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50"
    ]


X_train, y_train = load_data(Signers,"/kaggle/input/frames/dataForSigner1_2/dataForSigner1_2/train", Category)
X_test, y_test = load_data(Signers,"/kaggle/input/frames/dataForSigner1_2/dataForSigner1_2/test", Category)


lb = LabelBinarizer()
y_train = lb.fit_transform(y_train)
y_test = lb.transform(y_test)




base_model = ResNet50(weights="imagenet", include_top=False, input_tensor=Input(shape=(224, 224, 3)))
base_model.layers.pop()

input_tensor = Input(shape=(30, 224, 224, 3))


time_distributed_layer = TimeDistributed(base_model)(input_tensor)

flatten_layer = TimeDistributed(Flatten())(time_distributed_layer)


lstm_layer1 = LSTM(units=128, return_sequences=True)(flatten_layer)
lstm_layer2 = LSTM(units=64, return_sequences=False)(lstm_layer1)


mlp_layer = Dense(64, activation='relu')(lstm_layer2)


output_layer = Dense(15, activation='softmax')(mlp_layer)

model = Model(inputs=input_tensor, outputs=output_layer)


for l in base_model.layers:
    l.trainable = False


opt = Adam(learning_rate=0.00001)
model.compile(loss="categorical_crossentropy", optimizer=opt, metrics=["accuracy"])


batch_size = 30
num_epochs = 20

for epoch in range(num_epochs):
    print(f"Epoch {epoch+1}/{num_epochs}")
    for start in range(0, len(X_train), batch_size):
        end = min(start + batch_size, len(X_train))
        batch_X_train = X_train[start:end]
        batch_y_train = y_train[start:end]
        
        model.train_on_batch(batch_X_train, batch_y_train)
        
model.save("Resnet.h5")
model.save_weights('/kaggle/working/resnetWeights.h5')        

loss, accuracy = model.evaluate(X_test, y_test,batch_size=30)
print(f"Test Loss: {loss}, Test Accuracy: {accuracy}")


from keras.models import load_model
from keras.layers import Input, Concatenate, Dense
from keras.models import Model
import numpy as np
import os
import cv2

data = []
path = "/kaggle/input/data-set/data_set/test/0010/06_0010_(05_04_21_20_44_23)_c"
image_files = os.listdir(path)

for img_file in image_files:
    img_path = os.path.join(path, img_file)
    image = cv2.imread(img_path)
    data.append(image)

data = np.array(data)
data = np.expand_dims(data, axis=0)



model1 = load_model('/kaggle/working/Resnet.h5')


predictions1 = model1.predict(data)


print(predictions1)
max_prob_index = np.argmax(predictions1)


print(f"Class with max probability: {max_prob_index+1}")
