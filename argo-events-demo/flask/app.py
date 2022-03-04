from flask import Flask, render_template
import os

INSIDE_OUT_FOLDER = os.path.join('static', 'inside_out')

app = Flask(__name__)
app.config['INSIDE_OUT_FOLDER'] = INSIDE_OUT_FOLDER

image_name = 'sadness'

@app.route('/')
def show_index():
    global image_name
    full_filename = os.path.join(app.config['INSIDE_OUT_FOLDER'], image_name + '.jpg')
    return render_template("index.html", user_image = full_filename)

@app.route('/admin/<emotion>')
def change_image(emotion):
    global image_name
    image_name = emotion
    data = {"status": "success"}
    return data, 200


if __name__ == '__main__':
    app.run(host='0.0.0.0')
