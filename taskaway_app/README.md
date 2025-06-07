# Taskaway App

A modern task management application built with Flutter, Riverpod, and Supabase with AI-powered task breakdown capabilities.

## Features

- Create, edit, and delete tasks
- Mark tasks as completed
- Filter tasks by status (all, active, completed, deleted)
- Permanently delete or restore soft-deleted tasks
- Dark/light theme toggle
- Clean up old deleted tasks automatically
- AI-powered task breakdown with Groq API

## Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (2.10.0 or higher)
- [Dart](https://dart.dev/get-dart) (2.16.0 or higher)
- [Git](https://git-scm.com/)
- A code editor (VS Code, Android Studio, etc.)
- [Supabase](https://supabase.com/) account (free tier works fine)
- [Groq](https://groq.com/) API key (for AI features)

## Setup & Installation

### 1. Clone the repository
```bash
git clone https://github.com/shahswiene/Taskaway_Malaysia_Assessment.git
cd Taskaway_Malaysia_Assessment/taskaway_app
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Configure Supabase

1. Create a new Supabase project
2. Execute the following SQL in the Supabase SQL editor to create the tasks table:

```sql
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  is_deleted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

3. Copy your Supabase URL and anon key from the project settings
4. Create a `.env` file in the project root with the following content:

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GROQ_API_KEY=your_groq_api_key  # Optional, only needed for AI features
```

### 4. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── core/               # Core functionality and utilities
│   ├── constants/      # App-wide constants
│   ├── providers/      # App-wide providers
│   ├── theme/          # Theme configuration
│   └── utils/          # Utility functions
├── features/           # Feature modules
│   └── tasks/          # Tasks feature
│       ├── data/       # Data layer (repositories, models)
│       ├── domain/     # Domain layer (entities, use cases)
│       └── presentation/ # UI layer (screens, widgets)
└── main.dart          # Entry point
```

## Architecture

This app follows a clean architecture approach with the following layers:

- **Data Layer**: Handles external data sources and repositories
- **Domain Layer**: Contains business logic and entities
- **Presentation Layer**: Manages UI components and state

State management is handled using Riverpod with the following provider types:
- AsyncNotifierProvider for asynchronous state
- NotifierProvider for synchronous state

## Setup Instructions

### 1. Clone the repository

```bash
git clone <repository-url>
cd taskaway_app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure API Keys

Update the API keys in `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String groqApiKey = 'YOUR_GROQ_API_KEY'; // For AI features
}
```

### 4. Supabase Setup

1. Create a new project in Supabase
2. Create a table named `tasks` with the following structure:
   - `id` (uuid, primary key)
   - `title` (text, not null)
   - `is_completed` (boolean, default: false)
   - `created_at` (timestamp with time zone, default: now())
   - `updated_at` (timestamp with time zone, default: now())
   - `is_deleted` (boolean, default: false)

3. Create Row Level Security policies for anonymous access

### 5. Run the application

```bash
flutter run
```

Or for web deployment:

```bash
flutter run -d chrome 
or 
flutter run -d web-server --web-port 8080   
```

## Architecture

The app follows a clean architecture approach with:

- **Domain Layer**: Core business logic and models
- **Data Layer**: Repositories and data sources
- **Presentation Layer**: Screens, widgets, and state management

## State Management

The app uses Riverpod for state management with:

- `AsyncNotifier` for handling asynchronous states
- `StateProvider` for simple state

## AI Task Generation

The Smart Task Generator feature uses Groq's API (qwen-qwq-32b model) to break down complex tasks into manageable subtasks.

## Additional Notes

- The app uses Material 3 design
- For automated testing, run `flutter test`
- Web version may have some limitations with browser storage
