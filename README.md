# Fenix

A **clean‑architecture Flutter movie app** built as a technical case study.

This project demonstrates:

* Scalable architecture
* Offline‑first behavior
* State management with BLoC
* Dependency injection
* Localization & theming
* Favorites persistence
* Production‑ready code quality

---

# 🚀 Quick Setup

1. Install **Flutter 3.24+** and run:

   ```bash
   flutter doctor
   ```

2. Create a `.env` file at the repo root:

   ```env
   API_BASE_URL=https://api.themoviedb.org
   API_KEY=YOUR_TMDB_KEY
   IMAGE_BASE_URL=https://image.tmdb.org/t/p
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Generate code (DI, Freezed, JSON, routes, Hive):

   ```bash
   dart pub run build_runner build --delete-conflicting-outputs
   ```

5. Run tests:

   ```bash
   flutter test
   ```

6. Start the app:

   ```bash
   flutter run
   ```

> **Important:** Generated files are required after a fresh clone.

---

# 🧱 Architecture

The project follows **Clean Architecture** with strict layer separation:

```
lib/
 ├─ core/
 ├─ config/
 ├─ features/
 │   ├─ movies/
 │   └─ favorites/
```

### Layers

**Presentation**

* BLoC state management
* UI widgets
* Routing (AutoRoute)

**Domain**

* Entities
* UseCases
* Repository contracts

**Data**

* Remote & local data sources
* Models & mappers
* Repository implementations

---

# ⭐ Implemented Features

## 🎬 Movies

* Top‑rated movies listing
* Infinite scroll pagination
* Search support
* Offline cache fallback
* Network status awareness

## ❤️ Favorites

* Add/remove favorite movie
* Stored locally with **Hive**
* Real‑time UI sync between:

  * Home page
  * Favorites page
* Optimistic UI updates via BLoC

## 🌐 Offline‑First Behavior

* Cached movies shown when offline
* Offline search inside cache
* Automatic restore when connection returns

## 🎨 UI/UX

* Hero animations between list & detail
* Favorite toggle animations
* Responsive grid layout
* Dark / light theme support
* System‑locale fallback localization

## 🌍 Localization

* Easy Localization integration
* Device locale detection
* Fallback to supported language

## 🧪 Testing Ready

* Unit‑testable use cases
* Mockable repositories
* Deterministic BLoC logic

---

# 🔄 State Management Strategy

**BLoC is the single source of truth.**

Key principles:

* No business logic in UI
* Immutable states (Freezed)
* Predictable event → state flow
* Cross‑feature sync via shared domain layer

---

# 💾 Local Storage

**Hive** is used for:

* Cached movie pages
* Favorite movies persistence

Design goals:

* Fast startup
* Offline support
* Simple schema evolution

---

# 🧩 Dependency Injection

Uses **injectable + get_it**.

To regenerate DI:

```bash
dart pub run build_runner build
```

---

# 🛣 Routing

Powered by **AutoRoute**.

Features:

* Type‑safe navigation
* Nested routing ready
* Scalable for large apps

---

# 🧑‍💻 Development Guide

## Adding a New Feature

1. Create feature folder under `features/`
2. Add:

   * `data/`
   * `domain/`
   * `presentation/`
3. Follow existing movie feature as reference
4. Register dependencies in DI
5. Run build_runner

## Adding a New Use Case

* Place inside `domain/usecases`
* Keep **single responsibility**
* Return **Either<Failure, Result>**

## Writing a New Bloc

Rules:

* Events describe **what happened**
* States describe **UI condition**
* No repository calls outside use cases

---

# 📈 Possible Improvements

* Movie detail screen
* Remote favorites sync
* Advanced caching strategy
* Widget & golden tests
* CI/CD pipeline
* Analytics & crash reporting

---

# 🏁 Goal of This Project

This repository is designed as a **production‑quality Flutter case study** to demonstrate:

* Architecture knowledge
* Scalable state management
* Real‑world offline handling
* Clean, maintainable code

---

# 👋 Hire Me

If you are looking for a Flutter developer who cares about:

* Clean architecture
* Performance
* Maintainability
* Real product thinking

**Let’s talk.**

---

**PS:** I’m fully aware that this project is not winning any beauty contests in terms of fancy UI or cinematic animations. This is intentional. Since the provided brief mentioned that UI would not be part of the evaluation, I chose to invest the time in clean architecture, scalability, and maintainability instead of heroic gradients and emotionally moving micro‑interactions.

That said, if at any point you’d like to see this same codebase dressed up with delightful animations, polished design, and just a *tiny* bit of UI drama — I’d be more than happy to deliver the director’s cut. 🎬