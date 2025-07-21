# Doc2Quiz: AI-Powered Quiz Generator

Doc2Quiz is a Flutter mobile and web application that allows users to upload documents (PDF, DOCX, TXT) and instantly generate interactive quizzes using an Express.js backend powered by a Hugging Face AI model.

## 🌟 Features

-   **Document Upload**: Easily upload PDF, DOCX, or TXT files.
-   **AI-Powered Quiz Generation**: Leverages a Hugging Face model (via a custom backend API) to create intelligent multiple-choice questions from your document content.
-   **Difficulty Levels**: Choose between Easy, Medium, and Hard difficulty for your quizzes.
-   **Interactive Quiz Interface**: Take the generated quizzes directly within the app with real-time feedback.
-   **Review Answers**: Review your answers and see correct solutions after completing a quiz.
-   **Responsive Design**: Optimized for both mobile and web platforms.
-   **Animated UI**: Engaging and smooth animations enhance the user experience.

## 🚀 Technologies Used

**Frontend (Flutter)**:
-   `flutter/material.dart`: Core Flutter UI framework.
-   `file_picker`: For selecting files from the device/web.
-   `flutter_animate`: For stunning UI animations.
-   `http`: For making HTTP requests to the backend.
-   `dart:convert`, `dart:math`, `dart:typed_data`, `dart:ui`: Core Dart libraries.

**Backend (Node.js with Express)**:
-   `express`: Fast, unopinionated, minimalist web framework for Node.js.
-   `cors`: Middleware to enable Cross-Origin Resource Sharing.
-   `multer`: Middleware for handling `multipart/form-data`, primarily used for uploading files.
-   `node-fetch`: A light-weight module that brings `window.fetch` to Node.js.
-   `pdf-parse`: A utility to parse PDF files and extract text content.
-   **Hugging Face API**: (Implicitly used by the backend) For the AI model that generates quiz questions.

## ⚙️ Setup and Installation

This project consists of two main parts: the Flutter frontend and the Node.js Express backend.

### 1. Backend Setup

The backend is responsible for receiving documents, processing them, and interacting with the Hugging Face API to generate quiz questions.

**Prerequisites**:
-   Node.js (v14 or higher recommended)
-   npm (Node Package Manager)

**Steps**:

1.  **Navigate to the backend directory**:
    ```bash
    cd quiz-generator-api # Assuming your backend code is in this directory
    ```

2.  **Install dependencies**:
    ```bash
    npm install
    ```

3.  **Set up Environment Variables**:
    You might need to set up environment variables for your Hugging Face API token. Create a `.env` file in the backend root directory (if not already present) and add your token:
    ```
    HUGGING_FACE_API_TOKEN=YOUR_HUGGING_FACE_API_TOKEN
    ```
    *(Note: The provided `app.js` currently has an empty `huggingFaceToken` field in the frontend. You'll need to ensure your backend is configured to use the token securely, or pass it from the frontend if necessary.)*

4.  **Run the backend server**:
    ```bash
    npm start
    # Or for development with auto-restart:
    npm run dev
    ```
    The server will typically run on `http://localhost:3001`.

### 2. Frontend Setup

The frontend is a Flutter application that interacts with the backend.

**Prerequisites**:
-   Flutter SDK (v3.0.0 or higher recommended)
-   Dart SDK
-   A code editor (VS Code, Android Studio) with Flutter and Dart plugins.

**Steps**:

1.  **Navigate to the frontend directory**:
    ```bash
    cd doc2quiz-app # Assuming your frontend code is in this directory
    ```

2.  **Get Flutter dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Update Backend URL**:
    In `lib/quiz_generation_screen.dart`, locate the `_getBackendUrl()` method and ensure it points to your running backend server (e.g., `http://localhost:3001` for local development).
    ```dart
    String _getBackendUrl() {
      return 'http://localhost:3001'; // Make sure this matches your backend URL
    }
    ```

4.  **Run the Flutter application**:

    -   **For Web**:
        ```bash
        flutter run -d chrome
        ```
        (Or your preferred web browser)

    -   **For Android/iOS (Mobile)**:
        Connect a device or start an emulator/simulator, then run:
        ```bash
        flutter run
        ```

## 🔌 API Endpoints (Backend)

The Express.js backend exposes the following API endpoints:

-   **`GET /`**:
    -   **Description**: Root endpoint, returns a status message and available endpoints.
    -   **Response**:
        ```json
        {
          "status": "ok",
          "message": "Quiz Generator API is working",
          "timestamp": "...",
          "endpoints": [
            "GET / - This message",
            "GET /api/health - Health check",
            "POST /api/generate-quiz - Generate quiz from document"
          ]
        }
        ```

-   **`GET /api/health`**:
    -   **Description**: Health check endpoint to verify the API is running.
    -   **Response**:
        ```json
        {
          "status": "ok",
          "message": "API is healthy"
        }
        ```

-   **`POST /api/generate-quiz`**:
    -   **Description**: Generates a quiz from an uploaded document.
    -   **Method**: `POST`
    -   **Content-Type**: `multipart/form-data`
    -   **Fields**:
        -   `document`: (File) The document to process (PDF, DOCX, TXT).
        -   `numQuestions`: (Number, optional, default: 5) The desired number of questions.
        -   `difficulty`: (String, optional, default: 'medium') The difficulty level ('easy', 'medium', 'hard').
        -   `huggingFaceToken`: (String, optional) Your Hugging Face API token if not set as an environment variable on the server.
    -   **Response (Success)**:
        ```json
        {
          "success": true,
          "data": {
            "document_title": "Extracted Document Title",
            "quiz": [
              {
                "question": "What is the capital of France?",
                "options": ["Berlin", "Paris", "Rome", "Madrid"],
                "correct_answer": "Paris"
              },
              // ... more questions
            ]
          }
        }
        ```
    -   **Response (Error)**:
        ```json
        {
          "success": false,
          "error": "Error message details"
        }
        ```

## 📁 Project Structure

.├── backend/                  # Node.js Express API│   ├── app.js                # Main Express application file│   ├── package.json          # Backend dependencies and scripts│   ├── package-lock.json     # Locked dependencies│   └── routes/               # API routes (e.g., api.js for quiz generation)│       └── api.js├── frontend/                 # Flutter Application│   ├── lib/                  # Dart source files│   │   ├── main.dart         # Main entry point for the Flutter app│   │   ├── home_screen.dart  # Home screen for file selection and settings│   │   ├── quiz_generation_screen.dart # Screen for showing quiz generation progress│   │   └── quiz_results_screen.dart    # Screen for displaying quiz and results│   ├── pubspec.yaml          # Flutter project dependencies│   ├── pubspec.lock          # Locked Flutter dependencies│   └── ... (other Flutter project files)└── README.md                 # This file
## 🙏 Contributing

Contributions are welcome! Please feel free to open issues or submit pull requests.

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details.

---
Made with ❤️ by Aarav • Doc2Quiz v1.0
