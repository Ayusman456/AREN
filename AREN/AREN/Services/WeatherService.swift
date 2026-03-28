import Foundation

struct WeatherService {
    func fetchTodaySnapshot() async -> WeatherSnapshot {
        try? await Task.sleep(for: .milliseconds(120))

        return WeatherSnapshot(
            temperature: 31,
            humidity: 0.62,
            city: "Bengaluru"
        )
    }
}
