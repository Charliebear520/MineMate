import Foundation
import CoreData

class LoginRecordViewModel: ObservableObject {
    @Published var recordedDates: [Date] = []
    @Published var currentWeekOffset: Int = 0
    @Published var selectedDate: Date? = nil

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchRecordedDates()
    }

    func fetchRecordedDates() {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!)!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        fetchRequest.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", startOfWeek as NSDate, endOfWeek as NSDate)

        do {
            let records = try context.fetch(fetchRequest)
            recordedDates = records.compactMap { $0.timestamp }.map { calendar.startOfDay(for: $0) }
        } catch {
            print("Fetch error: \(error)")
        }
    }

    func goToPreviousWeek() {
        currentWeekOffset -= 1
        fetchRecordedDates()
    }

    func goToNextWeek() {
        currentWeekOffset += 1
        fetchRecordedDates()
    }

    func selectDate(_ date: Date) {
        selectedDate = date
    }
} 