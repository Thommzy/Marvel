//
//  MarvelCharacter.swift
//  WallapopMarvel
//
//  Created by Timothy  on 21/05/2022.
//

import Foundation

// MARK: - MarvelCharacter
struct MarvelCharacter: Codable {
    let code: Int?
    let status, copyright, attributionText, attributionHTML: String?
    let etag: String?
    let data: MarvelCharacterData?
}

// MARK: - MarvelCharacterData
struct MarvelCharacterData: Codable {
    let offset, limit, total, count: Int?
    let results: [MarvelCharacterDataResult]
}

// MARK: - MarvelCharacterDataResult
struct MarvelCharacterDataResult: Codable {
    let id: Int?
    let name, resultDescription: String?
    let modified: String?
    let thumbnail: Thumbnail?
    let resourceURI: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case resultDescription = "description"
        case modified, thumbnail, resourceURI
    }
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
    case gif = "gif"
    case jpg = "jpg"
}

// MARK: - URLElement
struct URLElement: Codable {
    let type: URLType?
    let url: String?
}

enum URLType: String, Codable {
    case comiclink = "comiclink"
    case detail = "detail"
    case wiki = "wiki"
}
