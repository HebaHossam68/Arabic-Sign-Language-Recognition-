from flask import Flask, request, jsonify

from realTime import Real_Time

App = Flask(__name__)
real = Real_Time()


@App.route('/')
def Start():
    predicted_class_label = real.main("02_0008_(06_03_21_19_31_20)c.mp4")
    print(predicted_class_label)
    return 'predictedclass_label' + predicted_class_label


@App.route('/predict', methods=['POST'])
def predict():
    print("Done")
    # Receive video file from Flutter
    video_file = request.files['video']
    # Save the video file
    video_path = 'video.mp4'  # Change the path as needed
    video_file.save(video_path)

    predicted_class_label, label = real.main(video_path)
    print(predicted_class_label)

    return jsonify({'predicted_class_label': predicted_class_label, 'label': label})


if __name__ == '__main__':
    App.run(host='0.0.0.0', port=5000, debug=True)
