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

## Supabase Setup

The repo now includes a safe Supabase configuration scaffold:

- [SupabaseConfiguration.swift](/Users/ayusmansahu/Documents/Developer/Xcode/AREN/AREN/AREN/Core/Services/Supabase/SupabaseConfiguration.swift)
- [SupabaseConfig.example.plist](/Users/ayusmansahu/Documents/Developer/Xcode/AREN/AREN/AREN/Resources/Config/SupabaseConfig.example.plist)

To finish local setup:

1. Add the official `supabase-swift` package in Xcode from `https://github.com/supabase/supabase-swift`.
2. Copy `SupabaseConfig.example.plist` to `SupabaseConfig.plist`.
3. Put your real `SUPABASE_URL` and `SUPABASE_ANON_KEY` in the untracked `SupabaseConfig.plist`.
4. Keep `SupabaseConfig.plist` out of Git. It is already ignored.

The app code is set up to prefer `SupabaseConfig.plist` and fall back to environment variables when present.

## Next Steps

- Add the missing starter app files such as `ContentView` and the initial SwiftData models
- Scaffold the first feature modules under `Features/Home` and `Features/Wardrobe`
- Add Supabase configuration through untracked local config
