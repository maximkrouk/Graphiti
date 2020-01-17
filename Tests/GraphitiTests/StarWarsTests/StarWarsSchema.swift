import Graphiti

let starWarsSchema = Schema<StarWarsAPI, StarWarsStore>([
    Enum(Episode.self) {
        Value(Episode.newHope)
        .description("Released in 1977.")

        Value(Episode.empire)
        .description("Released in 1980.")

        Value(Episode.jedi)
        .description("Released in 1983.")
    }
    .description("One of the films in the Star Wars Trilogy."),

    Interface(Character.self, fieldKeys: CharacterFieldKeys.self, [
        Field(CharacterFieldKeys.id, at: \.id)
        .description("The id of the character."),

        Field(CharacterFieldKeys.name, at: \.name)
        .description("The name of the character."),

        Field(CharacterFieldKeys.friends, at: \.friends, overridingType: [TypeReference<Character>].self)
        .description("The friends of the character, or an empty list if they have none."),

        Field(CharacterFieldKeys.appearsIn, at: \.appearsIn)
        .description("Which movies they appear in."),

        Field(CharacterFieldKeys.secretBackstory, at: \.secretBackstory)
        .description("All secrets about their past."),
    ])
    .description("A character in the Star Wars Trilogy."),

    Type(Planet.self, fields: [
        Field(Planet.FieldKey.id, at: \.id),
        Field(Planet.FieldKey.name, at: \.name),
        Field(Planet.FieldKey.diameter, at: \.diameter),
        Field(Planet.FieldKey.rotationPeriod, at: \.rotationPeriod),
        Field(Planet.FieldKey.orbitalPeriod, at: \.orbitalPeriod),
        Field(Planet.FieldKey.residents, at: \.residents, overridingType: [TypeReference<Human>].self),
    ])
    .description("A large mass, planet or planetoid in the Star Wars Universe, at the time of 0 ABY."),


    Type(Human.self, interfaces: Character.self, fields: [
        Field(Human.FieldKey.id, at: \.id),
        Field(Human.FieldKey.name, at: \.name),
        Field(Human.FieldKey.appearsIn, at: \.appearsIn),
        Field(Human.FieldKey.homePlanet, at: \.homePlanet),

        Field(Human.FieldKey.friends, at: Human.getFriends)
        .description("The friends of the human, or an empty list if they have none."),

        Field(Human.FieldKey.secretBackstory, at: Human.getSecretBackstory)
        .description("Where are they from and how they came to be who they are."),
    ])
    .description("A humanoid creature in the Star Wars universe."),

    Type(Droid.self, interfaces: Character.self, fields: [
        Field(Droid.FieldKey.id, at: \.id),
        Field(Droid.FieldKey.name, at: \.name),
        Field(Droid.FieldKey.appearsIn, at: \.appearsIn),
        Field(Droid.FieldKey.primaryFunction, at: \.primaryFunction),

        Field(Droid.FieldKey.friends, at: Droid.getFriends)
        .description("The friends of the droid, or an empty list if they have none."),

        Field(Droid.FieldKey.secretBackstory, at: Droid.getSecretBackstory)
        .description("Where are they from and how they came to be who they are."),
    ])
    .description("A mechanical creature in the Star Wars universe."),

    Union(SearchResult.self, members: Planet.self, Human.self, Droid.self),

    Query {
        Field(StarWarsAPI.FieldKey.hero, at: StarWarsAPI.getHero)
        .description("Returns a hero based on the given episode.")
        .argument(StarWarsAPI.FieldKey.episode, at: \.episode, description: "If omitted, returns the hero of the whole saga. If provided, returns the hero of that particular episode.")

        Field(StarWarsAPI.FieldKey.human, at: StarWarsAPI.getHuman)
        .argument(StarWarsAPI.FieldKey.id, at: \.id, description: "Id of the human.")

        Field(StarWarsAPI.FieldKey.droid, at: StarWarsAPI.getDroid)
        .argument(StarWarsAPI.FieldKey.id, at: \.id, description: "Id of the droid.")

        Field(StarWarsAPI.FieldKey.search, at: StarWarsAPI.search)
        .argument(StarWarsAPI.FieldKey.query, at: \.query, defaultValue: "R2-D2")
    },

    Types(Human.self, Droid.self),
])
