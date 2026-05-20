import Foundation

extension CleanerStore {
    func configureAutoCleanTimer() {
        autoCleanTimer?.invalidate()
        autoCleanTimer = nil

        guard autoCleanEnabled else {
            nextAutoCleanDate = nil
            defaults.removeObject(forKey: DefaultsKey.nextAutoCleanDate)
            return
        }

        scheduleNextAutoClean(from: Date())
    }

    func scheduleNextAutoClean(from date: Date) {
        autoCleanTimer?.invalidate()
        let nextDate = date.addingTimeInterval(autoCleanInterval.seconds)
        nextAutoCleanDate = nextDate
        defaults.set(nextDate, forKey: DefaultsKey.nextAutoCleanDate)

        autoCleanTimer = Timer.scheduledTimer(withTimeInterval: autoCleanInterval.seconds, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.autoCleanRecommended(trigger: .scheduled)
            }
        }
    }
}
