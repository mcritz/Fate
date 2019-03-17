import Vapor
import FluentPostgreSQL

extension FeaturedTopic: PostgreSQLUUIDModel {}
extension FeaturedTopic: Content {}
extension FeaturedTopic: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
        }
    }
}
extension FeaturedTopic: Parameter {}
extension FeaturedTopic {
    var topics: Children<FeaturedTopic, Topic> {
        return children(\.featuredTopicID)
    }
}
