import Graphiti

let starWarsSchema = Schema<StarWarsAPI, StarWarsStore> {
    Enum<StarWarsAPI, StarWarsStore, Episode>(Episode.self) {
        Value(Episode.newHope)
        .description("Released in 1977.")

        Value(Episode.empire)
        .description("Released in 1980.")

        Value(Episode.jedi)
        .description("Released in 1983.")
    }
    .description("One of the films in the Star Wars Trilogy.")

    Interface<StarWarsAPI, StarWarsStore, Character, CharacterFieldKeys>(Character.self, fieldKeys: CharacterFieldKeys.self) {
        Field<Character, CharacterFieldKeys, StarWarsStore, NoArguments, String, String>(CharacterFieldKeys.id, at: \.id)
        .description("The id of the character.")

        Field<Character, CharacterFieldKeys, StarWarsStore, NoArguments, String, String>(CharacterFieldKeys.name, at: \.name)
        .description("The name of the character.")

        Field<Character, CharacterFieldKeys, StarWarsStore, NoArguments, [TypeReference<Character>], [String]>(CharacterFieldKeys.friends, at: \.friends, overridingType: [TypeReference<Character>].self)
        .description("The friends of the character, or an empty list if they have none.")

        Field<Character, CharacterFieldKeys, StarWarsStore, NoArguments, [Episode], [Episode]>(CharacterFieldKeys.appearsIn, at: \.appearsIn)
        .description("Which movies they appear in.")

        Field<Character, CharacterFieldKeys, StarWarsStore, NoArguments, String?, String?>(CharacterFieldKeys.secretBackstory, at: \.secretBackstory)
        .description("All secrets about their past.")
    }
    .description("A character in the Star Wars Trilogy.")

    Type<StarWarsAPI, StarWarsStore, Planet>(Planet.self) {
        Field<Planet, Planet.FieldKey, StarWarsStore, NoArguments, String, String>(Planet.FieldKey.id, at: \.id)
        Field<Planet, Planet.FieldKey, StarWarsStore, NoArguments, String, String>(Planet.FieldKey.name, at: \.name)
        Field<Planet, Planet.FieldKey, StarWarsStore, NoArguments, Int, Int>(Planet.FieldKey.diameter, at: \.diameter)
        Field<Planet, Planet.FieldKey, StarWarsStore, NoArguments, Int, Int>(Planet.FieldKey.rotationPeriod, at: \.rotationPeriod)
        Field<Planet, Planet.FieldKey, StarWarsStore, NoArguments, Int, Int>(Planet.FieldKey.orbitalPeriod, at: \.orbitalPeriod)
        Field<Planet, Planet.FieldKey, StarWarsStore, NoArguments, [TypeReference<Human>], [Human]>(Planet.FieldKey.residents, at: \.residents, overridingType: [TypeReference<Human>].self)
    }
    .description("A large mass, planet or planetoid in the Star Wars Universe, at the time of 0 ABY.")


    Type<StarWarsAPI, StarWarsStore, Human>(Human.self, interfaces: Character.self) {
        Field<Human, Human.FieldKey, StarWarsStore, NoArguments, String, String>(Human.FieldKey.id, at: \.id)
        Field<Human, Human.FieldKey, StarWarsStore, NoArguments, String, String>(Human.FieldKey.name, at: \.name)
        Field<Human, Human.FieldKey, StarWarsStore, NoArguments, [Episode], [Episode]>(Human.FieldKey.appearsIn, at: \.appearsIn)
        Field<Human, Human.FieldKey, StarWarsStore, NoArguments, Planet, Planet>(Human.FieldKey.homePlanet, at: \.homePlanet)

        Field<Human, Human.FieldKey, StarWarsStore, NoArguments, [Character], [Character]>(Human.FieldKey.friends, at: Human.getFriends)
        .description("The friends of the human, or an empty list if they have none.")

        Field<Human, Human.FieldKey, StarWarsStore, NoArguments, String?, String?>(Human.FieldKey.secretBackstory, at: Human.getSecretBackstory)
        .description("Where are they from and how they came to be who they are.")
    }
    .description("A humanoid creature in the Star Wars universe.")

    Type<StarWarsAPI, StarWarsStore, Droid>(Droid.self, interfaces: Character.self) {
        Field<Droid, Droid.FieldKey, StarWarsStore, NoArguments, String, String>(Droid.FieldKey.id, at: \.id)
        Field<Droid, Droid.FieldKey, StarWarsStore, NoArguments, String, String>(Droid.FieldKey.name, at: \.name)
        Field<Droid, Droid.FieldKey, StarWarsStore, NoArguments, [Episode], [Episode]>(Droid.FieldKey.appearsIn, at: \.appearsIn)
        Field<Droid, Droid.FieldKey, StarWarsStore, NoArguments, String, String>(Droid.FieldKey.primaryFunction, at: \.primaryFunction)

        Field<Droid, Droid.FieldKey, StarWarsStore, NoArguments, [Character], [Character]>(Droid.FieldKey.friends, at: Droid.getFriends)
        .description("The friends of the droid, or an empty list if they have none.")

        Field<Droid, Droid.FieldKey, StarWarsStore, NoArguments, String?, String?>(Droid.FieldKey.secretBackstory, at: Droid.getSecretBackstory)
        .description("Where are they from and how they came to be who they are.")
    }
    .description("A mechanical creature in the Star Wars universe.")

    Union<StarWarsAPI, StarWarsStore, SearchResult>(SearchResult.self, members: Planet.self, Human.self, Droid.self)

    Query<StarWarsAPI, StarWarsStore> {
        Field(StarWarsAPI.FieldKey.hero, at: StarWarsAPI.getHero)
        .description("Returns a hero based on the given episode.")
        .argument(StarWarsAPI.FieldKey.episode, at: \.episode, description: "If omitted, returns the hero of the whole saga. If provided, returns the hero of that particular episode.")

        Field(StarWarsAPI.FieldKey.human, at: StarWarsAPI.getHuman)
        .argument(StarWarsAPI.FieldKey.id, at: \.id, description: "Id of the human.")

        Field(StarWarsAPI.FieldKey.droid, at: StarWarsAPI.getDroid)
        .argument(StarWarsAPI.FieldKey.id, at: \.id, description: "Id of the droid.")

        Field(StarWarsAPI.FieldKey.search, at: StarWarsAPI.search)
        .argument(StarWarsAPI.FieldKey.query, at: \.query, defaultValue: "R2-D2")
    }

    Types<StarWarsAPI, StarWarsStore>(Human.self, Droid.self)
}
