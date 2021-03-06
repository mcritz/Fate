import Foundation

final class User: Codable {
    var id: UUID?
    // FIXME: Neeed to validate email
    let email: String
    let username: String
    var password: String
    var permissions: Permissions
    init(id: UUID?, email: String, username: String?, password: String) {
        self.id = id
        self.email = email
        self.username = email
        self.password = password
        self.permissions = Permissions(privileges: [.createPrediction])
    }
}

final class Person: Codable {
    let id: UUID
    let username: String
    
    init(id: UUID, username: String) {
        self.id = id
        self.username = username
    }
}
