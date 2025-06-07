# Taskaway Malaysia Assessment

![Dart](https://img.shields.io/badge/Dart-56.9%25-blue)
![Flutter](https://img.shields.io/badge/Flutter-Framework-blue)
![Supabase](https://img.shields.io/badge/Supabase-Backend-green)
![Riverpod](https://img.shields.io/badge/Riverpod-State_Management-purple)

## Overview

This repository contains my submission for the Taskaway Malaysia Assessment, a Flutter task management application built with Supabase as the backend. The application demonstrates modern Flutter development practices, clean architecture, and AI-powered task management capabilities.

## Project Structure

- **`/taskaway_app/`**: The main Flutter application
  - Contains the complete source code, assets, and configuration files
  - Has its own detailed [README.md](./taskaway_app/README.md) with setup instructions

- **`/taskaway_app_uml/`**: UML diagrams for the application
  - Class diagrams
  - Component diagrams
  - Sequence diagrams
  - State flow diagrams

- **`demo_taskaway.mov`**: Video demonstration of the application

## Key Features

- Create, edit, and delete tasks
- Mark tasks as completed
- Filter tasks by status (all, active, completed, deleted)
- Dark/light theme toggle
- AI-powered task breakdown with Groq API

## Tech Stack

- **Frontend**: Flutter with Material 3 design
- **State Management**: Riverpod with AsyncNotifierProvider and NotifierProvider
- **Backend**: Supabase for database and authentication
- **Architecture**: Clean architecture with data, domain, and presentation layers
- **Code Generation**: Freezed for immutable models, Riverpod annotations
- **AI Integration**: Groq API for smart task breakdown

## Getting Started

For detailed setup instructions, please refer to the [taskaway_app README](./taskaway_app/README.md).

## Demo

A video demonstration of the application is available in the repository:
- [Demo Video](./demo_taskaway.mov)

## UML Diagrams

The application architecture is documented through various UML diagrams available in the `/taskaway_app_uml/` directory.

## Assessment Requirements

This project was built to meet the following requirements:

- Build a basic Flutter task app using Supabase
- Implement core functionality: add, list, edit, and delete tasks
- Create a database table with fields for id, title, completion status, and creation timestamp
- No login functionality required
- Bonus features implemented: task filtering and enhanced UI design
