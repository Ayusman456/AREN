import SwiftUI
import Combine

// MARK: - Destinations

enum AppDestination: Hashable {
    case wardrobeSearch
    case addItem
}

// MARK: - Sheets

enum AppSheet {
    case wardrobeFilters
    case dayDetail(date: Date, events: [DayDetailModalView.ScheduleEvent])
    case authSheet(context: AuthContext)
    case addItemSource
    case addItemCategory(id: UUID, image: UIImage)
}

extension AppSheet: Identifiable {
    var id: String {
        switch self {
        case .wardrobeFilters:                    return "wardrobeFilters"
        case .dayDetail:                          return "dayDetail"
        case .authSheet:                          return "authSheet"
        case .addItemSource:                      return "addItemSource"
        case .addItemCategory(let uuid, _):       return "addItemCategory-\(uuid)"
        }
    }
}

extension AppSheet: Hashable {
    static func == (lhs: AppSheet, rhs: AppSheet) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Router

@MainActor
final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var activeSheet: AppSheet?

    func navigate(to destination: AppDestination) {
        path.append(destination)
    }

    func present(sheet: AppSheet) {
        activeSheet = sheet
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
