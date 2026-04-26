# My Taste Brain

A Flutter MVP for a private, local-first food memory app.

The product direction is:

> A private food memory that learns what users save, cook, skip, and already have at home.

## MVP build order

The MVP is being built in this order:

1. Taste profile database
2. Saved recipes
3. Pantry + leftovers
4. Local search/matching
5. Local AI rewrite/suggestion

## What is implemented now

### 1. Taste profile database

The app now uses SQLite through `sqflite`.

Local profile data includes:

- preferred cuisines
- preferred tags
- disliked ingredients
- spice level
- max cooking time
- budget level
- diet notes

### 2. Saved recipes

Users can save recipes with:

- title
- ingredients
- tags
- source type
- source URL
- creator/source credit
- raw pasted text
- steps
- cooked count
- skipped count

There is also an import screen for pasted recipe captions/text.

### 3. Pantry + leftovers

Users can save pantry items and leftovers with:

- item name
- category
- quantity
- unit
- expiry date
- storage location
- leftover flag
- notes

The app shows:

- pantry items
- leftovers
- use-first items

### 4. Local search/matching

The local matcher ranks saved recipes using:

- available pantry items
- missing ingredients
- leftovers used
- expiring items used
- preferred tags
- cooked/skipped history
- disliked ingredient penalty

### 5. Local AI rewrite/suggestion scaffold

A `LocalAiService` is added as the boundary for Gemma 3 1B / MediaPipe style native integration.

The app also includes:

- OCR service wrapper for Google ML Kit text recognition
- voice input service wrapper for ML Kit GenAI speech recognition
- local fallback recipe text parser

## Current project structure

```text
lib/
  core/
    db/
      app_database.dart
    utils/
      csv_utils.dart
  data/
    auth_model.dart
    taste_memory.dart
  features/
    local_ai/
      local_ai_service.dart
      models/ai_suggestion.dart
    matching/
      models/recipe_match.dart
      services/recipe_matcher.dart
    ocr/
      ocr_service.dart
    pantry/
      data/pantry_repository.dart
      models/pantry_item.dart
    recipes/
      data/recipe_repository.dart
      services/recipe_text_parser.dart
    taste_profile/
      data/taste_profile_repository.dart
      models/taste_profile.dart
    voice/
      voice_input_service.dart
  models/
    recipe.dart
  screens/
    auth/
      login_screen.dart
      register_screen.dart
    pantry/
      add_pantry_item_screen.dart
      pantry_screen.dart
    taste_brain/
      taste_brain_screen.dart
    add_recipe_screen.dart
    home_screen.dart
    import_recipe_screen.dart
    recipe_detail_screen.dart
    saved_recipes_screen.dart
```

## Run locally

Make sure Flutter is installed, then run:

```bash
flutter pub get
flutter run
```

If this repository was created without iOS/Android folders, generate them first:

```bash
flutter create .
flutter pub get
flutter run
```

## Important MVP notes

- Auth is still local/demo only.
- SQLite data stays on device.
- OCR and voice wrappers are added, but native permissions and UI flows still need a follow-up pass.
- Local AI is scaffolded through a service boundary. Native Gemma/MediaPipe wiring still needs a platform-specific pass.
- The app should keep working without AI because the SQLite memory and matcher are the core product.
