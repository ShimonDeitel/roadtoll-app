import Foundation

struct Entry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var origin: String
    var destination: String
    var miles: Double
    var fuelCost: Double
    var date: Date = Date()
    var notes: String = ""
}
