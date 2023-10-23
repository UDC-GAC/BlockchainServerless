import os
from flask import Flask, request, jsonify
import subprocess
from minio import Minio
from minio.error import S3Error

app = Flask(__name__)

# MinIO configuration
minio_endpoint = "10.23.0.2:9000"
minio_access_key = "Rb5OCEAk9ODMDEIuYKIe"
minio_secret_key = "vJqQ54bPGvSLXHOiMLlbTapTR3qULpQDwZxBLdxL"
minio_bucket_name = "videos"

# Initialize MinIO client
minio_client = Minio(
    minio_endpoint,
    access_key=minio_access_key,
    secret_key=minio_secret_key,
    secure=False  # Change to True for secure connection (HTTPS)
)


# Function to download a file from MinIO and save it locally
def download_file_from_minio(minio_path, local_path):
    try:
        minio_client.fget_object(minio_bucket_name, minio_path, local_path)
        return True
    except S3Error as e:
        print(f"Error downloading file from MinIO: {e}")
        return False


# Function to upload an object to MinIO
def upload_to_minio(local_path, minio_path, bucket_name):
    try:
        minio_client.fput_object(bucket_name, minio_path, local_path)
        os.remove(local_path)  # Remove the temporary file after upload
        return True
    except S3Error as e:
        print(f"Error uploading file to MinIO: {e}")
        return False

def create_gif(input_path, output_path, duration):
    try:
        cmd = [
            "ffmpeg",
            "-y",
            "-i", input_path,
            "-t",
            "{0}".format(duration),
            "-vf",
            "fps=10,scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse",
            "-loop", "0",
            output_path
        ]
        subprocess.run(cmd, check=True)
        return True
    except Exception as e:
        print(f"Error creating GIF: {e}")
        return False


@app.route('/create_gif', methods=['POST'])
def create_gif_endpoint():
    data = request.json
    minio_path = data.get('minio_path')
    duration = data.get('duration')
    output_bucket = data.get('output')  # Add 'output' argument

    if not (minio_path and duration and output_bucket):
        return jsonify({'error': 'Missing input parameters'}), 400

    local_input_path = '/tmp/input_video.mp4'
    local_output_path = '/tmp/output.gif'

    if download_file_from_minio(minio_path, local_input_path):
        if create_gif(local_input_path, local_output_path, duration):
            modified_name = minio_path.rsplit('.', 1)[0] + '-processed.gif'
            if upload_to_minio(local_output_path, modified_name, output_bucket):
                os.remove(local_input_path)  # Remove the locally downloaded video file
                return jsonify({'message': f'GIF created and stored as {modified_name} in bucket {output_bucket}'}), 200
        else:
            return jsonify({'error': 'Failed to create GIF'}), 500
    else:
        return jsonify({'error': 'Failed to download input video from MinIO'}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
