import Foundation

struct PokemonListResults: Codable {
    let results: [PokemonListResult]
}

struct PokemonListResult: Codable {
    let name: String
    let url: String
}

struct PokemonResult: Codable {
    let id: Int
    let name: String
    let types: [PokemonTypeEntry]
    let sprites: ImageUrls
}

struct PokemonTypeEntry: Codable {
    let slot: Int
    let type: PokemonType
}

struct PokemonType: Codable {
    let name: String
}

struct PokeCatch {
    var CatchPokemons: [ String : Bool ] = [:]
}

struct ImageUrls: Codable {
    let back_default: String
    let front_default: String
}

struct PokemonDescription: Codable {
    let flavor_text_entries: [Description]
}

struct Description: Codable {
    let flavor_text: String
    let language: DescLang
}

struct DescLang: Codable {
    let name: String
    let url: String
}
