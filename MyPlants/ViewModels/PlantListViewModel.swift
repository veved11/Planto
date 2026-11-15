
import Combine
import Foundation

final class PlantListViewModel: ObservableObject {

    @Published private(set) var plants: [PlantReminder]

    private let storageService = PlantStorageService()

    init() {
        plants = storageService.loadPlants()
        resetDailyCompletionsIfNeeded()
    }

    var completedCount: Int {
        plants.filter(\.isDoneToday).count
    }

    func toggleDone(for plant: PlantReminder) {

        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else {
            return
        }

        plants[index].isDoneToday.toggle()

        if plants[index].isDoneToday {
            plants[index].lastCompletedDate = Date()
        } else {
            plants[index].lastCompletedDate = nil
        }

        savePlants()
    }

    func resetDailyCompletionsIfNeeded() {

        let calendar = Calendar.current
        var hasChanges = false

        for index in plants.indices {

            if plants[index].isDoneToday {
                let lastCompletedDate = plants[index].lastCompletedDate

                if let lastCompletedDate,
                   calendar.isDateInToday(lastCompletedDate) {
                    continue
                }

                plants[index].isDoneToday = false
                plants[index].lastCompletedDate = nil
                hasChanges = true
            }
        }

        if hasChanges {
            savePlants()
        }
    }

    func add(_ plant: PlantReminder) {
        plants.append(plant)
        savePlants()

        Task {
            await PlantNotificationService.shared.scheduleReminder(for: plant)
        }
    }

    func update(_ plant: PlantReminder, with updatedPlant: PlantReminder) {

        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else {
            return
        }

        plants[index].name = updatedPlant.name
        plants[index].room = updatedPlant.room
        plants[index].light = updatedPlant.light
        plants[index].wateringDays = updatedPlant.wateringDays
        plants[index].waterAmount = updatedPlant.waterAmount

        let savedPlant = plants[index]

        savePlants()

        Task {
            PlantNotificationService.shared.cancelReminder(for: plant)

            await PlantNotificationService.shared.scheduleReminder(
                for: savedPlant,
                identifier: plant.id
            )
        }
    }

    func delete(_ plant: PlantReminder) {
        plants.removeAll { $0.id == plant.id }
        savePlants()
        PlantNotificationService.shared.cancelReminder(for: plant)
    }

    private func savePlants() {
        storageService.savePlants(plants)
    }
}

