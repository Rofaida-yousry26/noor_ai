NOOR AI — Flutter Client

A Flutter-based client for NOOR AI, a document question-answering assistant that lets users work with PDF files and ask questions about their contents.

Overview

NOOR AI provides a mobile interface for interacting with a document-focused AI assistant. The Flutter client connects to a FastAPI backend for document operations and question answering.

The client is designed around a simple workflow:

Upload a PDF document.

View and manage indexed documents.

Ask questions about document content in a chat interface.

Review answers and available source references.

Navigate between the main application sections.

Key Features

The Flutter client has been developed around the following features:

PDF upload: select a PDF and send it to the backend for processing.

Document library: retrieve the document list from the backend, refresh it, search the list, and request document deletion.

AI chat: send a question to the backend and display the returned answer.

Source references: display source metadata returned by the API, such as document name and page number.

Language preference: pass the requested answer-language option (auto, ar, or en) to the backend where supported by the chat flow.

Theme controls: light/dark theme controls are included in the UI. Theme consistency across every route depends on the app-level theme state being shared by all screens.

Multi-screen navigation: separate screens organize the dashboard, chat, files, sources, and profile/settings experiences.

Feature note: this README describes the client functionality and API contract documented for the project. Verify each feature in the current build before presenting it as fully production-ready.

Technology Stack

Technology

Role

Flutter

Cross-platform application UI

Dart

Application programming language

FastAPI

Backend API consumed by the client

REST / JSON

Communication for questions and document metadata

HTTP multipart upload

Sending PDF files to the backend

Android Emulator

Local development and testing target

The backend handles document extraction, retrieval, and language-model inference. The Flutter app is responsible for user interaction, making API requests, and presenting the returned data.

Application Architecture

The client follows a screen-based Flutter structure, with API calls delegated to a service layer.

Flutter UI
├── Dashboard
├── Chat
├── Files / Documents
├── Sources
└── Profile / Settings
        │
        ▼
   API Service
        │  HTTP / JSON / multipart
        ▼
    FastAPI Backend
        ├── PDF upload and indexing
        ├── Document listing and deletion
        └── Question answering
                │
                ▼
       Retrieval + LLM pipeline

Responsibilities

Screens: render the interface and handle user interactions.

API service: centralize HTTP requests to the backend.

Backend: process uploaded PDFs, retrieve relevant document content, generate answers, and return source metadata.

Navigation and state: maintain the current screen and relevant UI state.

The project has used a screen-oriented structure and Flutter stateful widgets. Do not describe the application as using a specific state-management package or a fully implemented BLoC architecture unless that matches the current Flutter source code.

Backend Integration

Base URL

For an Android emulator communicating with a backend running on the development computer, the configured base URL has been:

http://10.0.2.2:8000

10.0.2.2 is the Android Emulator's special address for reaching the host machine. It is a local-development address, not a production API URL.

API Endpoints

Method

Endpoint

Purpose

GET

/hello

Basic backend connectivity check

POST

/upload

Upload a PDF as multipart form data

GET

/documents

Retrieve indexed document metadata

DELETE

/documents/{name}

Delete a document by name

POST

/ask

Submit a question and receive an answer with source metadata

Ask request example

{
  "question": "What is the main idea of this document?",
  "answer_language": "auto",
  "document": "example.pdf"
}

The document field is optional. Supported answer-language values in the documented backend contract are auto, ar, and en.

Ask response example

{
  "answer": "A response generated from the retrieved document context.",
  "sources": [
    {
      "document": "example.pdf",
      "page": 1
    }
  ]
}

These are illustrative payloads. Actual response content and source entries depend on the backend and indexed documents.

Project Structure

A suggested high-level structure for the Flutter client is shown below. Keep the paths aligned with the actual repository if its folders differ.

lib/
├── main.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── chat_screen.dart
│   ├── files_screen.dart
│   ├── sources_screen.dart
│   └── profile_screen.dart
├── services/
│   └── api_service.dart
└── widgets/
    └── reusable UI components

The tree above is a documentation template based on the app's screen responsibilities, not a guarantee of the exact current directory names.

Setup and Run

Prerequisites

Flutter SDK installed and configured.

Dart version supported by the Flutter SDK in use.

Android Studio or another configured Flutter development environment.

A running NOOR AI FastAPI backend.

The required Flutter packages listed in pubspec.yaml.

1. Get the project dependencies

From the Flutter project root:

flutter pub get

2. Start the backend

Start the FastAPI backend using the project's backend instructions. Confirm that it is listening on port 8000 if you intend to use the default emulator URL.

3. Configure the API base URL

For Android Emulator development, configure the client to use:

http://10.0.2.2:8000

For a physical device, use a reachable development-machine IP address and ensure the device and computer can communicate over the network. Do not use the emulator-only address on a physical phone.

4. Run the Flutter app

flutter run

5. Check the setup

Open the app and confirm that the dashboard renders.

Upload a small test PDF.

Confirm that the file appears in the document list.

Ask a question whose answer is present in the PDF.

Verify the answer and any returned source references.

Test document refresh and deletion.

Configuration and Reliability

Keep API configuration in one place rather than scattering base URLs throughout the UI.

Handle request timeouts and API errors with clear messages.

Show upload progress or a loading state for long-running requests.

Handle empty document lists and empty source lists gracefully.

Encode document names safely when constructing endpoint paths.

Do not expose secrets or private service credentials in the repository.

Use HTTPS and a deployment-specific base URL for production.

Confirm the backend's network binding and platform permissions when testing on a physical device.

Known Development Considerations

Local URL: http://10.0.2.2:8000 is for Android Emulator development only.

Theme state: if theme toggles are maintained separately in individual screens, the theme may not stay consistent after navigation. A shared app-level theme state is recommended.

In-memory chat data: chat history or citation history stored in static in-memory variables may not survive a full app restart.

PDF viewing: opening PDFs inside the app requires a configured PDF viewer route and a backend endpoint or other accessible file URL. Do not claim in-app PDF viewing is complete unless it is implemented and tested in the current build.

Release build: validate the release build separately from debug mode and resolve any R8/ProGuard errors before publishing.

Testing Checklist

App launches without runtime errors.

Backend connectivity succeeds.

PDF upload handles success and failure.

Document list loads, refreshes, and displays empty states.

Document deletion updates the UI and backend.

Chat sends questions and displays returned answers.

Source references display the correct document and page.

Arabic and English answer-language options behave as expected.

Loading indicators and timeouts are handled.

Light/dark theme behavior is consistent across screens.

Android release APK builds successfully.

Any in-app PDF viewer behavior is tested if included in the current build.

Screenshots and Demo

Add screenshots or a short demo video here to showcase the app's actual current UI.

Suggested screenshots:

Dashboard

PDF upload and document library

Chat response with source references

Sources screen

Profile/settings and theme controls

Example Markdown placeholders:

![NOOR AI Dashboard](screenshots/dashboard.png)
![Document Library](screenshots/files.png)
![AI Chat with Sources](screenshots/chat-sources.png)

Project Status

NOOR AI's Flutter client is the mobile interface for the document assistant. The current repository should be tested against the checklist above before describing all listed features as complete or publishing a release build.

License

Add the license appropriate for this repository before distributing the project publicly.
#   n o o r _ a i  
 