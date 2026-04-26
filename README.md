# My Taste Brain

A Flutter starter app for a private food memory experience.

The app helps users:

- Add ingredients they have at home.
- Save recipes with ingredients and optional tags.
- See recipe suggestions ranked by what they can cook with the fewest missing ingredients.
- Keep the early food-memory logic local inside the app.

## Current MVP

This first version is intentionally small. It does not use cloud AI yet. It focuses on the core product loop:

```text
ingredients at home + saved recipes = personalized recipe suggestions
```

## Project structure

```text
lib/
  main.dart
  data/
    taste_memory.dart
  models/
    recipe.dart
  screens/
    home_screen.dart
    add_recipe_screen.dart
    saved_recipes_screen.dart
```

## Run locally

Make sure Flutter is installed, then run:

```bash
flutter pub get
flutter run
```

## Next features

Good next steps:

- Add local persistence with Hive, Isar, Drift, or SQLite.
- Add a saved recipe import flow for copied Instagram/TikTok captions.
- Add a `What can I cook?` mode for ingredients at home.
- Add a `missing ingredients` grocery list.
- Add optional Instacart shopping-list integration later.
- Add on-device AI later for private taste insights.

## Product direction

This should not become a generic AI recipe app.

The stronger direction is:

> A private food memory that learns what users save, cook, skip, and already have at home.
