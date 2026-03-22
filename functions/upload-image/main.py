from flask import jsonify
from google.cloud import storage, pubsub_v1
import uuid

PROJECT_ID = "image-pipeline-456"
BUCKET_NAME = "image-pipeline-uploads-456"
TOPIC_ID = "image-processing-requests"

storage_client = storage.Client()
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)

def upload_image(request):
    if 'file' not in request.files:
        return jsonify({"error": "No file provided"}), 400

    file = request.files['file']
    filename = str(uuid.uuid4()) + "_" + file.filename

    bucket = storage_client.bucket(BUCKET_NAME)
    blob = bucket.blob(filename)
    blob.upload_from_file(file.stream)

    message = f"{BUCKET_NAME},{filename}"
    publisher.publish(topic_path, message.encode("utf-8"))

    return jsonify({
        "message": "Upload successful",
        "file": filename
    }), 202