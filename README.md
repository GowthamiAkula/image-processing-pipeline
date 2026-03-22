# Serverless Image Processing Pipeline on Google Cloud Platform

---

## 📌 Project Overview

This project demonstrates a **fully serverless, event-driven image processing pipeline** built using Google Cloud Platform services and Terraform.

The system allows users to securely upload images via an API Gateway. The uploaded images are processed asynchronously (converted to grayscale) and stored in a separate bucket. The pipeline uses Pub/Sub for decoupled communication between services.

---

## 🎯 Objectives

* Build a serverless architecture using GCP services
* Implement event-driven processing using Pub/Sub
* Secure APIs using API Gateway and API keys
* Manage infrastructure using Terraform (IaC)
* Apply lifecycle policies and IAM best practices

---

## 🏗️ Architecture

User → API Gateway → Upload Function → Cloud Storage (uploads)
→ Pub/Sub (requests) → Processing Function → Cloud Storage (processed)
→ Pub/Sub (results) → Notification Function → Cloud Logging

---

## ⚙️ Technologies Used

* Google Cloud Functions (Gen 2)
* Google Cloud Storage
* Google Cloud Pub/Sub
* Google API Gateway
* Google Secret Manager
* Terraform (Infrastructure as Code)
* Python (Flask, Pillow)

---

## 📁 Project Structure

```
image-processing-project/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── openapi.yaml
│
├── functions/
│   ├── upload-image/
│   ├── process-image/
│   └── log-notification/
│
├── README.md
├── submission.json
└── .gitignore
```

---

## 🏗️ Infrastructure Setup (Terraform)

### Step 1: Initialize Terraform

```
terraform init
```

### Step 2: Apply Configuration

```
terraform apply
```

Resources created:

* Storage buckets (uploads + processed)
* Pub/Sub topics
* IAM roles and service account
* Cloud Functions
* API Gateway

---

## ☁️ Resources Created

### 🔹 Cloud Storage

* image-pipeline-uploads-456

  * Lifecycle rule: deletes files after 7 days
* image-pipeline-processed-456

### 🔹 Pub/Sub Topics

* image-processing-requests
* image-processing-results

### 🔹 Cloud Functions

1. upload-image (HTTP trigger)
2. process-image (Pub/Sub trigger)
3. log-notification (Pub/Sub trigger)

### 🔹 API Gateway

Endpoint:

```
https://image-processing-gateway-9l8lxnoz.uc.gateway.dev/v1/images/upload
```

---

## 🔐 Security Implementation

* API Gateway secured using API Key
* API Key created using GCP API Keys service
* API Key stored securely in Secret Manager
* IAM roles follow least privilege principle

---

## 🔄 Workflow Explanation

1. User sends POST request via API Gateway

2. Upload Function:

   * Receives image
   * Uploads to uploads bucket
   * Publishes message to Pub/Sub

3. Processing Function:

   * Triggered by Pub/Sub
   * Downloads image
   * Converts to grayscale using Pillow
   * Uploads processed image

4. Notification Function:

   * Triggered by results topic
   * Logs success message

---

## 🧪 Testing the System

### Step 1: Upload Image

```
curl -X POST -H "x-api-key: YOUR_API_KEY" -F "file=@test.png" https://image-processing-gateway-9l8lxnoz.uc.gateway.dev/v1/images/upload
```

### Expected Response:

```
{
  "message": "Upload successful",
  "file": "xxxx.png"
}
```

---

### Step 2: Verify Upload Bucket

```
gsutil ls gs://image-pipeline-uploads-456
```

---

### Step 3: Verify Processed Output

```
gsutil ls gs://image-pipeline-processed-456
```

---

### Step 4: Check Logs

```
gcloud functions logs read log-notification --region=us-central1
```

---

## 📊 Features

* Fully serverless (no VM usage)
* Event-driven architecture
* Asynchronous processing using Pub/Sub
* Secure API with API Gateway and API key
* Infrastructure as Code using Terraform
* Automatic file cleanup using lifecycle rules

---

## ⚠️ Limitations

* Rate limiting not enforced (can be configured in API Gateway)
* Secret Manager not dynamically used in runtime (stored securely)

---

## 🧹 Cleanup

To delete all resources:

```
terraform destroy
```

---

## 📌 Key Learnings

* Hands-on experience with GCP serverless services
* Understanding of event-driven architectures
* API Gateway configuration and security
* IAM role management and debugging
* Terraform for cloud infrastructure automation

---

## 👨‍💻 Author

Gowthami Akula

---

## 🎉 Conclusion

This project successfully demonstrates a **scalable, secure, and event-driven serverless architecture** using Google Cloud Platform. It reflects real-world cloud engineering practices and production-level system design.
