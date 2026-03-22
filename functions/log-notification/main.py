import base64

def log_notification(event, context):
    if 'data' in event:
        message_data = base64.b64decode(event['data']).decode('utf-8')
        print("Image processed successfully:", message_data)
    else:
        print("No data received")
