import Foundation
/**
 * This defines a basic set of data for our Star Wars Schema.
 *
 * This data is hard coded for the sake of the demo, but you could imagine
 * fetching this data from a backend service rather than from hardcoded
 * values in a more complex demo.
 */
final class StarWarsStore {
    lazy var tatooine = Planet(
        id:"10001",
        name: "Tatooine",
        diameter: 10465,
        rotationPeriod: 23,
        orbitalPeriod: 304,
        residents: []
    )
    
    lazy var alderaan = Planet(
        id: "10002",
        name: "Alderaan",
        diameter: 12500,
        rotationPeriod: 24,
        orbitalPeriod: 364,
        residents: []
    )
    
    lazy var planetData: [String: Planet] = [
        "10001": tatooine,
        "10002": alderaan,
    ]
    
    lazy var luke = Human(
        id: UUID(uuidString: "B340240F-57AB-4AD6-A71F-EBFE5E7ACC6C")!,
        name: "Luke Skywalker",
        friends: [
            UUID(uuidString: "0511AC38-E359-43AA-827F-9666279BD280")!,
            UUID(uuidString: "ECA47EF3-022B-4398-9E20-EC64594C3BAE")!,
            UUID(uuidString: "35A0D0AF-98B9-4BA8-A12B-D24D7BD078F9")!,
            UUID(uuidString: "5F3F16DE-B5BC-49B9-B280-313171F71E47")!
        ],
        appearsIn: [.newHope, .empire, .jedi],
        homePlanet: tatooine
    )
    
    lazy var vader = Human(
        id: UUID(uuidString: "E6FA5B00-304E-4D9A-A36B-C23E87F2C0A5")!,
        name: "Darth Vader",
        friends: [ UUID(uuidString: "5767F52A-130A-4D3B-A3AE-03757683BD82")! ],
        appearsIn: [.newHope, .empire, .jedi],
        homePlanet: tatooine
    )
    
    lazy var han = Human(
        id: UUID(uuidString: "0511AC38-E359-43AA-827F-9666279BD280")!,
        name: "Han Solo",
        friends: [
            UUID(uuidString: "B340240F-57AB-4AD6-A71F-EBFE5E7ACC6C")!,
            UUID(uuidString: "ECA47EF3-022B-4398-9E20-EC64594C3BAE")!,
            UUID(uuidString: "5F3F16DE-B5BC-49B9-B280-313171F71E47")!
        ],
        appearsIn: [.newHope, .empire, .jedi],
        homePlanet: alderaan
    )
    
    lazy var leia = Human(
        id: UUID(uuidString: "ECA47EF3-022B-4398-9E20-EC64594C3BAE")!,
        name: "Leia Organa",
        friends: [
            UUID(uuidString: "B340240F-57AB-4AD6-A71F-EBFE5E7ACC6C")!,
            UUID(uuidString: "0511AC38-E359-43AA-827F-9666279BD280")!,
            UUID(uuidString: "35A0D0AF-98B9-4BA8-A12B-D24D7BD078F9")!,
            UUID(uuidString: "5F3F16DE-B5BC-49B9-B280-313171F71E47")!
        ],
        appearsIn: [.newHope, .empire, .jedi],
        homePlanet: alderaan
    )
    
    lazy var tarkin = Human(
        id: UUID(uuidString: "5767F52A-130A-4D3B-A3AE-03757683BD82")!,
        name: "Wilhuff Tarkin",
        friends: [UUID(uuidString: "E6FA5B00-304E-4D9A-A36B-C23E87F2C0A5")!],
        appearsIn: [.newHope],
        homePlanet: alderaan
    )
    
    lazy var humanData: [UUID: Human] = [
        UUID(uuidString: "B340240F-57AB-4AD6-A71F-EBFE5E7ACC6C")!: luke,
        UUID(uuidString: "E6FA5B00-304E-4D9A-A36B-C23E87F2C0A5")!: vader,
        UUID(uuidString: "0511AC38-E359-43AA-827F-9666279BD280")!: han,
        UUID(uuidString: "ECA47EF3-022B-4398-9E20-EC64594C3BAE")!: leia,
        UUID(uuidString: "5767F52A-130A-4D3B-A3AE-03757683BD82")!: tarkin,
    ]
    
    lazy var c3po = Droid(
        id: UUID(uuidString: "35A0D0AF-98B9-4BA8-A12B-D24D7BD078F9")!,
        name: "C-3PO",
        friends: [
            UUID(uuidString: "B340240F-57AB-4AD6-A71F-EBFE5E7ACC6C")!,
            UUID(uuidString: "0511AC38-E359-43AA-827F-9666279BD280")!,
            UUID(uuidString: "ECA47EF3-022B-4398-9E20-EC64594C3BAE")!,
            UUID(uuidString: "5F3F16DE-B5BC-49B9-B280-313171F71E47")!
        ],
        appearsIn: [.newHope, .empire, .jedi],
        primaryFunction: "Protocol"
    )
    
    lazy var r2d2 = Droid(
        id: UUID(uuidString: "5F3F16DE-B5BC-49B9-B280-313171F71E47")!,
        name: "R2-D2",
        friends: [
            UUID(uuidString: "B340240F-57AB-4AD6-A71F-EBFE5E7ACC6C")!,
            UUID(uuidString: "0511AC38-E359-43AA-827F-9666279BD280")!,
            UUID(uuidString: "ECA47EF3-022B-4398-9E20-EC64594C3BAE")!
        ],
        appearsIn: [.newHope, .empire, .jedi],
        primaryFunction: "Astromech"
    )
    
    lazy var droidData: [UUID: Droid] = [
        UUID(uuidString: "35A0D0AF-98B9-4BA8-A12B-D24D7BD078F9")!: c3po,
        UUID(uuidString: "5F3F16DE-B5BC-49B9-B280-313171F71E47")!: r2d2,
    ]
    
    /**
     * Helper function to get a character by ID.
     */
    func getCharacter(id: UUID) -> Character? {
        humanData[id] ?? droidData[id]
    }
    
    /**
     * Allows us to query for a character"s friends.
     */
    func getFriends(of character: Character) -> [Character] {
        character.friends.compactMap { id in
            getCharacter(id: id)
        }
    }
    
    /**
     * Allows us to fetch the undisputed hero of the Star Wars trilogy, R2-D2.
     */
    func getHero(of episode: Episode?) -> Character {
        if episode == .empire {
            // Luke is the hero of Episode V.
            return luke
        }
        // R2-D2 is the hero otherwise.
        return r2d2
    }
    
    /**
     * Allows us to query for the human with the given id.
     */
    func getHuman(id: UUID) -> Human? {
        humanData[id]
    }
    
    /**
     * Allows us to query for the droid with the given id.
     */
    func getDroid(id: UUID) -> Droid? {
        droidData[id]
    }
    
    /**
     * Allows us to get the secret backstory, or not.
     */
    func getSecretBackStory() throws -> String? {
        struct Secret : Error, CustomStringConvertible {
            let description: String
        }
        
        throw Secret(description: "secretBackstory is secret.")
    }
    
    /**
     * Allows us to query for a Planet.
     */
    func getPlanets(query: String) -> [Planet] {
        planetData
            .sorted(by: { $0.key < $1.key })
            .map({ $1 })
            .filter({ $0.name.lowercased().contains(query.lowercased()) })
    }
    
    /**
     * Allows us to query for a Human.
     */
    func getHumans(query: String) -> [Human] {
        humanData
            .map({ $1 })
            .filter({ $0.name.lowercased().contains(query.lowercased()) })
    }
    
    /**
     * Allows us to query for a Droid.
     */
    func getDroids(query: String) -> [Droid] {
        droidData
            .map({ $1 })
            .filter({ $0.name.lowercased().contains(query.lowercased()) })
    }

    /**
     * Allows us to query for either a Human, Droid, or Planet.
     */
    func search(query: String) -> [SearchResult] {
        return getPlanets(query: query) + getHumans(query: query) + getDroids(query: query)
    }
}
