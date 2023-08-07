//
//  Status.swift
//  Quictionary
//
//  Created by Marco Vasquez on 4/5/23.
//  Enum representing status of an entry

import Foundation

// An entry's status can be seen, unseen, or excluded
public enum Status: String {
    case unseen, seen, excluded
}
