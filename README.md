# SpeakZed — Regional Zambian Learning Hub

SpeakZed is an offline-first Flutter app for learning everyday phrases in Bemba, Nyanja, and Tonga. It was built for CS301 (Group 19) as a phrasebook, pronunciation guide, and quiz app aimed at helping users pick up common expressions in Zambian languages.

## Features

- **Phrasebook** — browse phrases by category (Greetings, Travel, Shopping, Social) with translations across English, Bemba, Nyanja, and Tonga.
- **Search** — live keyword search across all phrases and translations.
- **Favorites** — save phrases for quick access later.
- **Translate** — a two-tab screen: a flashcard study deck for practicing phrase-by-phrase, and a text-lookup tool for quick translations against the local phrasebook.
- **Quiz Challenge** — multiple-choice and free-recall quiz questions generated from the phrasebook, with a results screen and progress history (best/average score, past attempts).
- **Accounts** — local sign-up/sign-in and a profile screen showing quiz stats (lessons completed, streak, points).
- **Pronunciation** — tap-to-hear audio on any phrase.

## Architecture

The app follows a 3-layer structure:

- **Presentation Layer** — screens under `lib/screens/`, reusable widgets under `lib/widgets/`.
- **Application Logic Layer** — services under `lib/services/` (`PhrasebookService`, `QuizService`, `FavoritesService`, `AuthService`, `AudioService`, `QuizProgressService`).
- **Data Layer** — phrase data in `assets/data/phrases.json`; user data (favorites, accounts, quiz history) stored locally via **Hive**.

The app is entirely offline — there is no backend/server. Accounts and all user data live only on the device they were created on.

## Known limitations (current state)

- **Pronunciation audio** currently uses on-device text-to-speech (`flutter_tts`) as a placeholder. Bemba, Nyanja, and Tonga are not supported by standard TTS engines, so pronunciation for those languages is approximate. Real recorded audio is planned to replace this (see `assets/audio/` once added).
- **Phrase translations** in `assets/data/phrases.json` are draft content and should be reviewed by a fluent speaker of each language before being treated as authoritative.
- **Speech-to-text** on the quiz's free-recall screen is a visual placeholder (mic icon) and not yet functional.
- **Accounts are local-only** — there is no server, so an account created on one device/emulator does not exist anywhere else, and credentials are not securely hashed. This is an intentional trade-off of the offline-first design, not an oversight.

## Getting started

```bash
flutter pub get
flutter run
```

Requires the Flutter SDK and an Android emulator or device.