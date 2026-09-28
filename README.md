# Expense Tracker (Flutter + Firebase)

A simple, clean expense tracker built with Flutter and Firebase Firestore.
Built as a practical task submission for the CyphLab Flutter Developer
Internship.

## Features Implemented

- Add, edit, and delete expenses (swipe-to-delete with confirmation)
- Each expense: title, amount, category, date, optional note
- Expenses stored and synced live via Cloud Firestore
- Current month's total spend, shown at the top of the home screen
- Full expense history list, newest first
- Filter by category (chip bar) and by date range (date-range picker)
- Search by title/note
- Form validation (required title, numeric amount > 0)
- Loading / empty / error states handled explicitly throughout
- Donut chart of this month's spending by category
- Dark mode toggle, persisted across restarts
- Firebase Authentication: every device signs in anonymously on first
  launch, so each user's expenses are private to them (enforced by
  Firestore security rules, not just app-side filtering)

## Tech Stack

- Flutter (Dart)
- `firebase_core`, `cloud_firestore`, `firebase_auth`
- `provider` for state management
- `fl_chart` for the category breakdown chart
- `intl` for currency/date formatting
- `shared_preferences` for persisting the dark-mode setting

## Project Structure

```
lib/
  models/expense.dart              # Expense data model + category list
  services/expense_service.dart    # Firestore CRUD + live stream
  services/auth_service.dart       # Anonymous sign-in
  providers/expense_provider.dart  # App state: data, filters, totals
  providers/theme_provider.dart    # Dark mode state
  screens/home_screen.dart         # Main list + totals + filters
  screens/add_edit_expense_screen.dart  # Add/edit form
  widgets/                         # Reusable UI pieces
  utils/                           # Formatting + theme helpers
```

## Setup Instructions

### 1. Prerequisites
- Flutter SDK installed (`flutter --version` to check)
- A free [Firebase](https://console.firebase.google.com) account
- Node.js (only needed to install the Firebase CLI in step 2)

### 2. Create the Firebase project and connect it
This project ships with a **placeholder** `lib/firebase_options.dart` —
you must replace it with your own, or the app won't build.

```bash
# one-time global installs
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# log in to Firebase
firebase login

# from inside this project folder:
flutter create .              # regenerates android/ ios/ web/ folders
flutterfire configure         # walks you through picking/creating a
                               # Firebase project and writes real
                               # firebase_options.dart for you
```
When `flutterfire configure` asks which platforms to support, choose at
least Android (fastest to test on an emulator).

### 3. Enable Firestore and Anonymous Auth in the Firebase Console
- Console → Build → **Firestore Database** → Create database (test mode
  is fine to start; production rules are provided in `firestore.rules` —
  deploy them with `firebase deploy --only firestore:rules`, or paste
  them into the Rules tab in the console).
- Console → Build → **Authentication** → Sign-in method → enable
  **Anonymous**.

### 4. Install packages and run
```bash
flutter pub get
flutter run
```

### 5. Build a release APK (for the optional APK link)
```bash
flutter build apk --release
# output at: build/app/outputs/flutter-apk/app-release.apk
```

## AI Tools Used

_(Fill this in honestly based on what you actually used — for example:)_

- Used Claude to scaffold the initial project structure (models, Firestore
  service layer, Provider-based state management, screens, and widgets),
  then reviewed, ran, and adjusted the generated code myself.
- Used Claude to help design the Firestore security rules that scope
  each user's expenses to their own anonymous auth `uid`.
- [Add anything else you personally used it for, or other tools like
  GitHub Copilot / ChatGPT, and what each helped with.]

## Notes

- Data is scoped per-device via Firebase Anonymous Authentication —
  there's no login screen, but each installation gets its own private
  set of expenses, enforced server-side by `firestore.rules`.
- The category list is a fixed set (`lib/models/expense.dart`) rather
  than user-defined, to keep the scope focused on the core requirements.
