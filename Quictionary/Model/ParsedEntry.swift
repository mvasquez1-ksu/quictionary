//
//  ParsedEntry.swift
//  Quictionary
//
//  Created by Marco Vasquez on 4/25/23.
//  Struct used to create DictionaryEntry objects from JSON file format

import Foundation

struct ParsedEntry: Codable {
    let word: String
    let definition: String
    let type: String
    let l1_exampleSentences: [String]
    let l2_exampleSentences: [String]
    let pronunciation: String
}
