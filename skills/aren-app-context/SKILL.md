---
name: aren-app-context
description: >
  Full product and technical context for ARĒN — an AI-powered wardrobe app for the Indian market.
  Use this skill for ANY task related to the ARĒN app: writing Swift code, designing features,
  planning architecture, building database queries, creating AI prompts, writing API logic,
  or making product decisions. Trigger whenever the user mentions ARĒN, wardrobe app, outfit
  engine, clothing items, SwiftUI wardrobe, Supabase wardrobe, or any feature from this product.
---

# ARĒN — App Context Skill

## Current Repository Reality

The current workspace at `/Users/ayusmansahu/Documents/Developer/Xcode/AREN` is still at a very early scaffold stage.

Observed structure right now:

```text
/Users/ayusmansahu/Documents/Developer/Xcode/AREN
├── AREN/
│   ├── AREN.xcodeproj
│   └── AREN/
│       ├── ARENApp.swift
│       └── Assets.xcassets
└── skills/
    └── aren-app-context/
```

Important current-state constraints:

- The only app source file currently present is `AREN/AREN/ARENApp.swift`
- `ARENApp.swift` references `ContentView()` and `Item.self`
- `ContentView.swift` does not exist yet in the repo
- No `Item` SwiftData model exists yet in the repo
- No feature folders, services, design system, or Supabase integration are implemented yet

When using this skill for implementation tasks:

- Treat the product architecture in this skill as the target architecture, not as already-built code
- Verify the repo state before assuming a module, service, or screen already exists
- Prefer incremental scaffolding that moves the repo toward the target folder structure
- Keep new code aligned with SwiftUI + MVVM + SwiftData + Supabase boundaries described below

## What ARĒN Is

ARĒN is an AI-powered personal wardrobe OS for the Indian market. It is NOT a shopping app
or a catalogue tool. It is a daily style decision engine, answering one question every morning:

> "What should I wear today?"

The AI connects three things: the user's real wardrobe, their real day (calendar + weather),
and their personal style. The core user contract is: open the app, see your outfit, go live your day.

## Target User

- Urban Indian professionals, 23-35
- Tier 1 cities: Mumbai, Delhi, Bengaluru, Hyderabad, Pune
- Hybrid wardrobe reality: Western + Ethnic clothing
- Shops across Myntra, AJIO, Zara, H&M
- High smartphone dependency, low patience for friction

## Tech Stack — Non-Negotiable

| Layer | Technology | Notes |
|-------|-----------|-------|
| UI | SwiftUI | All screens, native only. No UIKit. |
| State | `@ObservableObject` / `@StateObject` | MVVM pattern |
| Local DB | SwiftData | Offline cache + canvas debounce buffer |
| Reactive | Combine | Async data streams |
| Image loading | Nuke | Remote image caching |
| On-device AI | VisionKit (iOS 17+) | Background removal, free and offline |
| Backend | Supabase | Auth + PostgreSQL + Storage + Edge Functions |
| AI - tagging + outfits | OpenAI GPT-4V | Core intelligence |
| AI - flat-lay (post-PMF) | DALL-E 3 | Deferred until post-revenue |
| BG removal fallback | Remove.bg | $0.20/image, cloud fallback only |
| Weather | Open-Meteo API | Free, hyperlocal |
| Calendar | EventKit (native iOS) | Local, no API cost |
| Payments | RevenueCat | Subscription management |
| Minimum iOS | iOS 17 | Required for VisionKit background removal |

## Architecture — Four Layers

```text
CLIENT LAYER (iOS App - SwiftUI)
├── Home Screen
├── Wardrobe Manager
├── Canvas Editor
└── Discover & Boards

LOCAL LAYER (On-Device)
├── SwiftData - offline cache, canvas state buffer
├── VisionKit - background removal (free, on-device)
└── EventKit - calendar (local, no API)

BACKEND LAYER (Supabase)
├── Auth Service (Apple Sign In + JWT)
├── PostgreSQL Database
├── Storage Buckets (clothing images)
└── Edge Functions (AI proxy, webhooks)

EXTERNAL SERVICES
├── OpenAI GPT-4V - outfit generation + garment tagging
├── DALL-E 3 - flat-lay composition (post-PMF only)
├── Open-Meteo - weather
├── Remove.bg - BG removal fallback
└── RevenueCat - subscriptions
```

## Database Schema — Complete

### `users`

```sql
id UUID PK | email TEXT | username TEXT
style_mode TEXT -- 'western' | 'ethnic' | 'both'
created_at TIMESTAMP
```

### `clothing_items`

```sql
id UUID PK | user_id FK
image_url TEXT
processed_image_url TEXT
category TEXT
color TEXT | brand TEXT | tags TEXT[]
style_mode TEXT
occasion TEXT
fabric TEXT
ai_confidence FLOAT DEFAULT 0
is_available BOOLEAN DEFAULT true
wear_count INT DEFAULT 0
last_worn_at TIMESTAMP
created_at TIMESTAMP
```

### `outfits`

```sql
id UUID PK | user_id FK | name TEXT | created_at TIMESTAMP
```

### `outfit_items` — Canvas State

```sql
id UUID PK | outfit_id FK | clothing_id FK
position_x FLOAT | position_y FLOAT
scale FLOAT DEFAULT 1 | rotation FLOAT DEFAULT 0 | layer INT DEFAULT 0
```

### `outfit_history` — Wear Log

```sql
id UUID PK | user_id FK | outfit_id FK
worn_at TIMESTAMP DEFAULT now()
occasion TEXT | weather_snapshot JSONB
```

### `style_boards`

```sql
id UUID PK | user_id FK | title TEXT
cover_image_url TEXT | is_public BOOLEAN DEFAULT false | created_at TIMESTAMP
```

### `style_board_items`

```sql
id UUID PK | board_id FK | clothing_id FK (nullable)
source_url TEXT | price DECIMAL | retailer TEXT
status TEXT -- saved | in_cart | purchased
position_x FLOAT | position_y FLOAT | scale FLOAT DEFAULT 1 | layer INT DEFAULT 0
```

## Image Pipeline — Critical Order

```text
1. User captures photo
2. VisionKit on-device background removal (FREE, iOS 17+)
   └── Low confidence? -> Remove.bg API fallback ($0.20/img)
3. Transparent PNG generated (processed_image_url)
4. Upload BOTH to Supabase Storage:
   clothing-images/{user_id}/raw/{item_id}.jpg
   clothing-images/{user_id}/processed/{item_id}.png
5. Save both URLs to clothing_items table
```

Rule: background removal must happen before Supabase upload. Never store raw photos only.

## AI Outfit Generation — Prompt Structure

```text
Context sent to GPT-4V:
- Wardrobe items: [{id, category, color, fabric, occasion, style_mode}]
- Weather: {temp, humidity, city} from Open-Meteo
- Calendar: {event_name, time} from EventKit (local)
- Avoid: [last 5 outfit_history outfit_ids]
- User style_mode: western | ethnic | both
- Return: JSON array of clothing_item IDs only
```

Rules:

- Always return item IDs as JSON, never descriptions
- Never suggest an outfit with items worn in last 5 days
- Fabric awareness: suggest linen/cotton in high humidity, not polyester
- If calendar event = formal/meeting, override casual suggestions

## AI Garment Tagging — Confidence Rule

```text
GPT-4V analyses processed PNG:
Returns: { category, color[], occasion, fabric, style_mode, confidence }

confidence >= 0.70 -> pre-populate tags for user confirmation
confidence < 0.70  -> flag for manual review, show warning UI
NEVER auto-save tags to DB without user confirmation
```

## Canvas Editor — Save Pattern

```text
User drags item
-> Update SwiftData IMMEDIATELY (zero latency, feels native)
-> Debounce 800ms
-> Batch save to Supabase outfit_items table
```

Never save to Supabase on every drag event. Canvas must feel instant.

## Flat-lay Composition

MVP (free): programmatic SwiftUI layout using processed PNGs

- Shirt/top -> centre top position
- Trousers -> below shirt
- Shoes -> foot position, slightly below trousers
- Bag -> offset right
- Drop shadow per item via SwiftUI `.shadow()`

Post-PMF: DALL-E 3 at about $0.04/image. Do not implement until post-revenue.

## Wardrobe Mode — Indian Market Logic

Every clothing item and user has a `style_mode`:

```swift
enum WardrobeMode: String {
    case western = "western"
    case ethnic = "ethnic"
    case both = "both"
}
```

The AI outfit engine must respect `style_mode`:

- User mode = `western` -> never suggest ethnic items
- User mode = `ethnic` -> prioritise kurta, saree, sherwani, lehenga etc.
- User mode = `both` -> allow fusion outfits

Indian ethnic categories to support:
`kurta`, `sherwani`, `lehenga`, `saree`, `salwar`, `dupatta`, `dhoti`, `bandhgala`, `anarkali`

## Limited Wardrobe Mode

If `clothing_items` count is under 20:

- Shift home screen from suggestion engine to wardrobe building coach
- Show Outfit Maximiser with all possible combinations from current items
- Show Gap Priority such as "Navy chino pairs with 4 of your 6 items"
- Do not force AI outfit suggestions with fewer than 20 items

## MVVM Pattern — Always Follow

```swift
// View -> ViewModel -> Service -> Supabase/API

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    // Never call Supabase directly from View
}

class HomeViewModel: ObservableObject {
    @Published var outfit: Outfit?
    private let outfitService = OutfitService()

    func loadTodaysOutfit() async {
        outfit = try? await outfitService.generateOutfit()
    }
}

class OutfitService {
    func generateOutfit() async throws -> Outfit {
        // calls Supabase + OpenAI
    }
}
```

## Folder Structure

```text
AREN/
├── App/              ARENApp.swift
├── Core/
│   ├── Models/       SwiftData models
│   ├── ViewModels/   ObservableObject classes
│   ├── Services/     API, AI, Weather, Calendar
│   └── Extensions/
├── Features/
│   ├── Onboarding/
│   ├── Home/
│   ├── Wardrobe/
│   ├── Canvas/
│   ├── Boards/
│   └── Profile/
├── DesignSystem/     HMColors, HMTypography, HMSpacing, HMComponents
└── Resources/        Assets.xcassets
```

This folder structure is the intended destination structure. If the repo is still sparse, create it progressively rather than assuming it already exists.

## Working Rules For This Repo

- Use SwiftUI only for UI code. Do not introduce UIKit unless the user explicitly asks for it.
- Keep business logic out of views. Views render state and forward user actions.
- Put external integration code behind services before wiring it into view models.
- Use SwiftData as the local-first state layer for items, outfits, and canvas persistence.
- Treat Supabase as the remote source of truth for sync, auth, storage, and edge functions.
- Never hardcode secrets, API keys, Supabase URLs, or anon keys in checked-in source.
- If a file referenced by the architecture does not exist yet, create the smallest viable version instead of mocking large unfinished systems.
- Respect the product constraints in this skill even when scaffolding, especially cost controls and the image pipeline order.

## Permissions — Deferred Pattern

Never request permissions at launch or during onboarding.
Request each permission only at the moment the user triggers that feature:

| Permission | Request When |
|-----------|-------------|
| Camera | User taps Add Item for first time |
| Photo Library | User taps Add Item and chooses library |
| Calendar | User enables calendar context in settings |
| Location | User enables weather in settings |

## API Endpoints Reference

```text
POST /auth/signup | POST /auth/login | GET /auth/user

POST   /clothing              Upload item + processed image URL
GET    /clothing              Paginated wardrobe fetch
PATCH  /clothing/{id}         Update tags, availability, wear count
DELETE /clothing/{id}

POST   /outfits               Create outfit
GET    /outfits/{id}          Load canvas state
PATCH  /outfits/{id}          Debounced canvas layout save

POST   /history               Log outfit worn (WEAR TODAY tap)
GET    /history/recent        Last 5 (home screen strip)

POST   /ai/generate-outfit    Daily suggestion with full context
POST   /ai/tag-item           Garment auto-tagging on upload
POST   /ai/gap-analysis       Wardrobe gap detection
```

## Cost Rules — Never Violate

| Action | Cost | Rule |
|--------|------|------|
| Background removal | Free | VisionKit always first |
| Garment tagging | ~$0.04/item | Tag once only, cache forever |
| Outfit generation | ~$0.04/call | 1 call per user per day max |
| Flat-lay composition | Free (MVP) | Programmatic only until post-PMF |
| DALL-E flat-lay | ~$0.04/image | Do not implement pre-PMF |

Core principle: tag once, cache aggressively. Never retag an item.

## Supabase Client Initialisation

```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"]!)!,
    supabaseKey: ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"]!
)
```

Never hardcode the Supabase URL or anon key in source files.

## Business Model

| Tier | Price | Limits |
|------|-------|--------|
| Free | INR 0 | 30 items, 1 suggestion/day |
| Style+ Monthly | INR 299/month | Unlimited, full AI, calendar sync |
| Style+ Annual | INR 2,499/year | All above + influencer match |

Additional: affiliate commissions 4-8% on gap-item purchases as primary Year 1 revenue.

## What This App Is Not

- Not a social feed or community app
- Not a shopping catalogue
- Not a brand promotional tool
- Not a general fashion inspiration app
- No ads, no algorithmic feed, no engagement metrics

The only metric that matters: did the user wear the outfit today?
