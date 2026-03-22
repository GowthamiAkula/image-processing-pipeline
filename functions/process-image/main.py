import base64
from google.cloud import storage, pubsub_v1
from PIL import Image
import io

PROJECT_ID = "image-pipeline-456"
OUTPUT_BUCKET = "image-pipeline-processed-456"
RESULT_TOPIC = "image-processing-results"

storage_client = storage.Client()
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(PROJECT_ID, RESULT_TOPIC)

def process_image(event, context):
    # Decode Pub/Sub message
    message_data = base64.b64decode(event['data']).decode('utf-8')
    bucket_name, file_name = message_data.split(",")

    # Download image
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)
    image_bytes = blob.download_as_bytes()

    # Convert to grayscale
    image = Image.open(io.BytesIO(image_bytes)).convert("L")

    # Save to memory
    output_buffer = io.BytesIO()
    image.save(output_buffer, format="PNG")
    output_buffer.seek(0)

    # Upload processed image
    output_bucket = storage_client.bucket(OUTPUT_BUCKET)
    output_blob = output_bucket.blob("processed_" + file_name)
    output_blob.upload_from_file(output_buffer, content_type="image/png")

    # Publish result message
    result_message = f"{OUTPUT_BUCKET},processed_{file_name}"
    publisher.publish(topic_path, result_message.encode("utf-8"))

    print("Processed:", file_name)