import Graphiti

let starWarsSchema = QLSchema<StarWarsAPI, StarWarsStore>([
    QLEnum(Episode.self, [
        QLValue(.newHope)
        .description("Released in 1977."),

        QLValue(.empire)
        .description("Released in 1980."),

        QLValue(.jedi)
        .description("Released in 1983."),
    ])
    .description("One of the films in the Star Wars Trilogy."),

    QLInterface(Character.self, fieldKeys: CharacterFieldKeys.self, [
        QLField(.id, at: \.id)
        .description("The id of the character."),

        QLField(.name, at: \.name)
        .description("The name of the character."),

        QLField(.friends, at: \.friends, overridingType: [QLTypeReference<Character>].self)
        .description("The friends of the character, or an empty list if they have none."),

        QLField(.appearsIn, at: \.appearsIn)
        .description("Which movies they appear in."),

        QLField(.secretBackstory, at: \.secretBackstory)
        .description("All secrets about their past."),
    ])
    .description("A character in the Star Wars Trilogy."),

    QLType(Planet.self, fields: [
        QLField(.id, at: \.id),
        QLField(.name, at: \.name),
        QLField(.diameter, at: \.diameter),
        QLField(.rotationPeriod, at: \.rotationPeriod),
        QLField(.orbitalPeriod, at: \.orbitalPeriod),
        QLField(.residents, at: \.residents, overridingType: [QLTypeReference<Human>].self),
    ])
    .description("A large mass, planet or planetoid in the Star Wars Universe, at the time of 0 ABY."),


    QLType(Human.self, interfaces: Character.self, fields: [
        QLField(.id, at: \.id),
        QLField(.name, at: \.name),
        QLField(.appearsIn, at: \.appearsIn),
        QLField(.homePlanet, at: \.homePlanet),

        QLField(.friends, at: Human.getFriends)
        .description("The friends of the human, or an empty list if they have none."),

        QLField(.secretBackstory, at: Human.getSecretBackstory)
        .description("Where are they from and how they came to be who they are."),
    ])
    .description("A humanoid creature in the Star Wars universe."),

    QLType(Droid.self, interfaces: Character.self, fields: [
        QLField(.id, at: \.id),
        QLField(.name, at: \.name),
        QLField(.appearsIn, at: \.appearsIn),
        QLField(.primaryFunction, at: \.primaryFunction),

        QLField(.friends, at: Droid.getFriends)
        .description("The friends of the droid, or an empty list if they have none."),

        QLField(.secretBackstory, at: Droid.getSecretBackstory)
        .description("Where are they from and how they came to be who they are."),
    ])
    .description("A mechanical creature in the Star Wars universe."),

    QLUnion(SearchResult.self, members: Planet.self, Human.self, Droid.self),

    QLQuery([
        QLField(.hero, at: StarWarsAPI.getHero)
        .description("Returns a hero based on the given episode.")
        .argument(.episode, at: \.episode, description: "If omitted, returns the hero of the whole saga. If provided, returns the hero of that particular episode."),

        QLField(.human, at: StarWarsAPI.getHuman)
        .argument(.id, at: \.id, description: "Id of the human."),

        QLField(.droid, at: StarWarsAPI.getDroid)
        .argument(.id, at: \.id, description: "Id of the droid."),

        QLField(.search, at: StarWarsAPI.search)
        .argument(.query, at: \.query, defaultValue: "R2-D2"),
    ]),

    QLTypes(Human.self, Droid.self),
])
