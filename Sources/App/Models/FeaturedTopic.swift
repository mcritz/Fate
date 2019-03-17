import Foundation

final class FeaturedTopic: Codable {
    var id: UUID?
    var priority: Int
    init(priority: Int) {
        self.priority = priority
    }
}
