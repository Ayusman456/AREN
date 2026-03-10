# AREN

ARĒN is an AI-powered wardrobe app for the Indian market, designed as a daily outfit decision engine rather than a shopping or catalog app.

## Current Status

This repository currently contains:

- An Xcode iOS app scaffold in [AREN](/Users/ayusmansahu/Documents/Developer/Xcode/AREN/AREN)
- A structured SwiftUI folder layout for the target architecture
- A local Codex skill for ARĒN product and technical context in [skills/aren-app-context](/Users/ayusmansahu/Documents/Developer/Xcode/AREN/skills/aren-app-context)

Current app structure:

```text
AREN/
├── AREN.xcodeproj
└── AREN/
    ├── App/
    ├── Core/
    │   ├── Extensions/
    │   ├── Models/
    │   ├── Services/
    │   └── ViewModels/
    ├── DesignSystem/
    ├── Features/
    │   ├── Boards/
    │   ├── Canvas/
    │   ├── Home/
    │   ├── Onboarding/
    │   ├── Profile/
    │   └── Wardrobe/
    └── Resources/
```

## Tech Direction

- SwiftUI for all UI
- MVVM for presentation and state flow
- SwiftData for local-first persistence
- Supabase for auth, database, storage, and edge functions
- OpenAI and supporting services for tagging and outfit generation

## Security Notes

This repo is set up to avoid committing common secrets and local-only config:

- `.env` files are ignored
- Xcode user-specific files are ignored
- common secret-bearing Apple config files such as `Secrets.plist`, `Config.plist`, `GoogleService-Info.plist`, and `*.xcconfig` are ignored
- private key files such as `*.p8` are ignored

Do not hardcode credentials in source files. Use environment-driven configuration or local untracked config files.

## Next Steps

- Add the missing starter app files such as `ContentView` and the initial SwiftData models
- Scaffold the first feature modules under `Features/Home` and `Features/Wardrobe`
- Add Supabase configuration through untracked local config
