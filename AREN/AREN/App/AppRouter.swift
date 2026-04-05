//
//  AppRouter.swift.swift
//  AREN
//
//  Created by Ayusman sahu on 05/04/26.
//

import SwiftUI
import Combine

enum AppDestination: Hashable {
    case wardrobeSearch
    case addItem
}

enum AppSheet: Identifiable, Hashable {
    case wardrobeFilters
    case authSheet(context: AuthContext)

    var id: Self { self }
}

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
