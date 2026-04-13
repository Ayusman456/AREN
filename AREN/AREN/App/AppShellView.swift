import SwiftUI

struct AppShellView: View {
    @StateObject private var router = AppRouter()
    @State private var activeTab: HomeTabBarItem = .home
    @State private var isPresentingWardrobeFilters = false
    @State private var isPresentingDayDetail = false
    @State private var dayDetailDate: Date = .now
    @State private var dayDetailEvents: [DayDetailModalView.ScheduleEvent] = []
    @State private var isAddingEventFromDayDetail = false
    @State private var showAddItemSource = false
    @State private var wardrobeSelectedFilterValues: [String: String] = [
        "01-sort by": "Recently added",
        "02-status": "All",
        "03-occasion": "All",
    ]

    var body: some View {
        ZStack(alignment: .bottom) {

            // MARK: - Main content + tab bar
            VStack(spacing: 0) {
                NavigationContainer(activeTab: activeTab, showAddItemSource: $showAddItemSource)
                    .environmentObject(router)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                HomeTabBarView(activeItem: activeTab) { item in
                    if item == activeTab {
                        router.popToRoot()
                    } else {
                        activeTab = item
                        router.popToRoot()
                    }
                }
            }
            .background(ArenColor.Surface.primary.ignoresSafeArea())

            // MARK: - Wardrobe filter panel
            if isPresentingWardrobeFilters {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { isPresentingWardrobeFilters = false }

                WardrobeFilterPanelView(
                    selectedValues: wardrobeSelectedFilterValues,
                    onSelectOption: { sectionID, option in
                        wardrobeSelectedFilterValues[sectionID] = option
                    },
                    onViewResults: { isPresentingWardrobeFilters = false }
                )
                .frame(maxWidth: .infinity)
                .background(ArenColor.Surface.primary)
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }

            // MARK: - Add item source sheet
            if showAddItemSource {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { showAddItemSource = false }

                AddItemSourceSheetView(isPresented: $showAddItemSource) { image in
                    VisionBGRemover.process(image: image) { result in
                        switch result {
                        case .success(let cleanImage):
                            Task {
                                guard let userID = await SupabaseService.shared.currentUserID() else {
                                    print("No active session")
                                    return
                                }
                                do {
                                    let itemID = UUID()
                                    let url = try await SupabaseService.shared.uploadClothingImage(cleanImage, itemID: itemID)
                                    let category = await ClothingClassifier.classify(cleanImage)
                                    let id = try await SupabaseService.shared.insertClothingItem(
                                        userID: userID,
                                        processedImageURL: url,
                                        category: category
                                    )
                                    print("Saved clothing item: \(id)")
                                } catch {
                                    print("Upload failed: \(error)")
                                }
                            }
                        case .failure(let error):
                            print("BG removal failed: \(error)")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(ArenColor.Surface.primary)
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(4)
            }

            // MARK: - Day detail modal
            if isPresentingDayDetail {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        isPresentingDayDetail = false
                        router.activeSheet = nil
                    }

                DayDetailModalView(
                    date: dayDetailDate,
                    events: dayDetailEvents,
                    isAddingEvent: $isAddingEventFromDayDetail
                )
                .frame(maxWidth: .infinity, alignment: .bottom)
                .background(ArenColor.Surface.primary)
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(2)
            }
        }
        .animation(.easeOut(duration: 0.2), value: isPresentingWardrobeFilters)
        .animation(.easeOut(duration: 0.2), value: isPresentingDayDetail)
        .animation(.easeOut(duration: 0.2), value: showAddItemSource)
        .onReceive(router.$activeSheet) { sheet in
            if sheet == .wardrobeFilters {
                isPresentingWardrobeFilters = true
                isPresentingDayDetail = false
                router.activeSheet = nil
            } else if case .dayDetail(let date, let events) = sheet {
                dayDetailDate = date
                dayDetailEvents = events
                isPresentingDayDetail = true
                isPresentingWardrobeFilters = false
                isAddingEventFromDayDetail = false
                router.activeSheet = nil
            }
        }
    }
}

#Preview {
    AppShellView()
}
