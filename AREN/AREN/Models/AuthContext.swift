import Foundation

enum AuthContext: String, Identifiable {
    case join
    case save
    case nudge

    var id: String { rawValue }

    var title: String {
        switch self {
        case .join:
            return "Join ARĒN"
        case .save:
            return "Save your outfit state"
        case .nudge:
            return "Link your identity"
        }
    }

    var message: String {
        switch self {
        case .join:
            return "Keep your anonymous wardrobe, then link Apple or Google when you are ready."
        case .save:
            return "Attach this session to a real account before saving more looks."
        case .nudge:
            return "Anonymous mode is active. Link a provider next so your wardrobe follows you across devices."
        }
    }
}
