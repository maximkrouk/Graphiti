import Foundation

enum Episode : String, Codable {
    case newHope = "NEWHOPE"
    case empire = "EMPIRE"
    case jedi = "JEDI"
}

protocol Character : Codable {
    var id: UUID { get }
    var name: String { get }
    var friends: [UUID] { get }
    var appearsIn: [Episode] { get }
}

struct Planet : Codable {
    let id: String
    let name: String
    let diameter: Int
    let rotationPeriod: Int
    let orbitalPeriod: Int
    var residents: [Human]
}

struct Human : Character {
    let id: UUID
    let name: String
    let friends: [UUID]
    let appearsIn: [Episode]
    let homePlanet: Planet
}

struct Droid : Character {
    let id: UUID
    let name: String
    let friends: [UUID]
    let appearsIn: [Episode]
    let primaryFunction: String
}

protocol SearchResult {}
extension Planet: SearchResult {}
extension Human: SearchResult {}
extension Droid: SearchResult {}
