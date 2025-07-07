# 🤟 Arabic Sign Language Recognition (ASLR)

## 🎓 Graduation Project

This project aims to **bridge the communication gap** between the **deaf community** and the broader **Arabic-speaking society** through the development of an **Arabic Sign Language Recognition (ASLR)** application.

---

## 🚀 Overview

Our ASLR system captures Arabic sign language gestures in **real-time** and translates them into **written Arabic text** (and optionally audio). This promotes **accessibility**, **inclusion**, and **real-time communication** for the deaf and hard-of-hearing community.

---

## ✨ Key Features

- 🔴 **Real-Time Sign Language Detection**  
  Captures and processes live video to detect and interpret ARSL gestures instantly using deep learning.

- 📝 **Arabic Text & Audio Translation**  
  Recognized signs are converted into written Arabic and optionally spoken aloud for seamless communication.

- 👩‍💻 **User-Friendly Interface**  
  The application features an intuitive, accessible UI designed for both ARSL users and non-signers.

---

## 🧠 Technologies & Tools

| Category         | Tools & Frameworks                        |
|------------------|-------------------------------------------|
| Language         | Python                                    |
| Deep Learning    | ResNet50, MobileNetV2                     |
| Backend          | Flask (REST API)                          |
| Frontend         | Flutter (Mobile Integration)              |

---

## 🧩 System Architecture

```mermaid
graph TD
A[Camera Input] --> B[Frame Preprocessing]
B --> C[Deep Learning Model (ResNet50 / MobileNetV2)]
C --> D[Gesture Classification]
D --> E[Arabic Text Generation]
E --> F[Display on Flutter App]

