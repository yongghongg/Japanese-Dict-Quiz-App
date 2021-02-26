//
//  WordModel.swift
//  Japanese Dict Quiz App
//
//  Created by Tan Yong Hong.
//

import Foundation

struct WordData: Codable {
    var data: [DetailedData]
}

struct DetailedData: Codable {
    var slug: String
    var japanese: [Japanese]
    var senses: [English]
}

struct Japanese: Codable {
    var reading: String?
}

struct English: Codable {
    var english_definitions: [String]
}
