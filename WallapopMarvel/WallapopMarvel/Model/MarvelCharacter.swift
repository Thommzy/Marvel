//
//  MarvelCharacter.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Foundation

// MARK: - MarvelCharacter
struct MarvelCharacter: Codable {
    let data: MarvelCharacterData?
}
// MARK: - MarvelCharacterData
struct MarvelCharacterData: Codable {
    let results: [MarvelCharacterDataResult]
}
// MARK: - MarvelCharacterDataResult
struct MarvelCharacterDataResult: Codable {
    let name: String
    let resultDescription: String?
    let thumbnail: Thumbnail?
    let comics, series: Comics?
    let stories: Stories?
    enum CodingKeys: String, CodingKey {
        case name
        case resultDescription = "description"
        case thumbnail, comics, series, stories
    }
}
// MARK: - Comics
struct Comics: Codable {
    let available: Int?
}
// MARK: - ComicsItem
struct ComicsItem: Codable {
    let name: String?
}
// MARK: - Stories
struct Stories: Codable {
    let available: Int?
}
// MARK: - Thumbnail
struct Thumbnail: Codable {
    let path: String?
    let thumbnailExtension: Extension?

    enum CodingKeys: String, CodingKey {
        case path
        case thumbnailExtension = "extension"
    }
}
enum Extension: String, Codable {
    case gif
    case jpg
}
