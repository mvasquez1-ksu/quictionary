//
//  DictionaryModel.swift
//  Quictionary
//
//  Created by Marco Vasquez on 2/17/23.
//  Acts as model layer of application

import Foundation
import CoreData


class DictionaryModel {
    // The Core Data managed object context
    private let context: NSManagedObjectContext
    // All dictionary entries
    private var entries: [DictionaryEntry]
    // All study lists
    private var studyLists: [StudyList]
    
    // Initiates the model class by loading all core data objects
    init(context: NSManagedObjectContext) {
        self.context = context
        self.entries = []
        self.studyLists = []
        self.loadEntries()
        self.loadStudyLists()
        // Temporary Test Code Below
        //resetContext()
    }
    
    // Loads dictionary entries from persistent store
    func loadEntries() {
        importEntriesFromJSON()
        let request: NSFetchRequest<DictionaryEntry> = DictionaryEntry.fetchRequest()
        do {
            self.entries = try context.fetch(request)
        } catch let error {
            print("An error occurred while fetching dictionary entries: \(error.localizedDescription)")
        }
    }
    
    // Loads study lists from persistent store
    func loadStudyLists() {
        let request: NSFetchRequest<StudyList> = StudyList.fetchRequest()
        do {
            self.studyLists = try context.fetch(request)
        } catch let error {
            print("An error occurred while fetching study lists: \(error.localizedDescription)")
        }
    }
    
    // From https://praveenkommuri.medium.com/how-to-read-parse-local-json-file-in-swift-28f6cec747cf
    // Reads from a local JSON file with the given name
    func readLocalJSONFile(forName name: String) -> Data? {
        do {
            if let filePath = Bundle.main.path(forResource: name, ofType: "json") {
                let fileUrl = URL(fileURLWithPath: filePath)
                let data = try Data(contentsOf: fileUrl)
                return data
            }
        } catch {
            print("error: \(error)")
        }
        return nil
    }
    
    // From https://praveenkommuri.medium.com/how-to-read-parse-local-json-file-in-swift-28f6cec747cf
    // Parses JSON data into ParsedEntry objects, which are later made into DictionaryEntry objects
    func parse(jsonData: Data) -> [ParsedEntry]? {
        do {
            let decodedData = try JSONDecoder().decode([ParsedEntry].self, from: jsonData)
            return decodedData
        } catch {
            print("error: \(error)")
        }
        return nil
    }
    
    // Creates a DictionaryEntry object for each ParsedEntry object parsed from the local JSON file
    func importEntriesFromJSON() {
        let jsonData = readLocalJSONFile(forName: "it-en")
        if let data = jsonData {
            if let parsedEntries = parse(jsonData: data) {
                for parsedEntry in parsedEntries {
                    let e = DictionaryEntry(context: context)
                    e.word = parsedEntry.word
                    e.definition = parsedEntry.definition
                    e.type = parsedEntry.type
                    e.l1exampleSentences = parsedEntry.l1_exampleSentences
                    e.l2exampleSentences = parsedEntry.l2_exampleSentences
                    e.pronunciation = parsedEntry.pronunciation
                    e.lastReviewed = Date()
                    e.nextReviewDate = Date()
                    e.status = Status.unseen.rawValue
                    e.reviewInterval = 0.5
                    e.consecutiveCount = 0
                    e.forgetCount = 0
                    e.difficulty = 0.3
                }
            }
        }
        saveContext()
    }
    
    // Adds a DictionaryEntry to the model's list of entries (only really used for testing)
    func addEntry(entry: DictionaryEntry) {
        entries.append(entry)
    }
    
    // Creates a new study list with a given title
    func createStudyList(title: String) {
        let newList = StudyList(context: context)
        newList.title = title
        newList.count = 0
        studyLists.append(newList)
    }
    
    // Deletes given study list
    func deleteStudyList(_ studyList: StudyList) {
        let index = studyLists.firstIndex(of: studyList)
        studyLists.remove(at: index!)
        for entry in studyList.entries! {
            removeEntryFromStudyList(entry: entry as! DictionaryEntry, studyList: studyList)
        }
        context.delete(studyList)
    }
    
    // Updates the last reviewed date and next review date of an entry using its review interval
    func updateReviewDate(entry: DictionaryEntry) {
        if entry.reviewInterval < 0 {
            entry.reviewInterval = 0.5
        }
        entry.lastReviewed = Date()
        //entry.nextReviewDate = entry.lastReviewed! + (86400 * Double(entry.reviewInterval))
        entry.nextReviewDate = entry.lastReviewed?.addingTimeInterval(max(86400 * Double(entry.reviewInterval), 86400))
    }
    
    // Adds entry to a study list
    func addEntryToStudyList(entry: DictionaryEntry, studyList: StudyList) {
        studyList.addToEntries(entry)
        studyList.count += 1
    }
    
    // Removes entry from a study list
    func removeEntryFromStudyList(entry: DictionaryEntry, studyList: StudyList) {
        studyList.removeFromEntries(entry)
        studyList.count -= 1
    }
    
    // Sets an entry's status
    func setEntryStatus(entry: DictionaryEntry, status: String) {
        entry.status = status;
    }
    
    // Returns all study lists
    func getStudyLists() -> [StudyList] {
        return studyLists
    }
    
    // Returns all entries
    func getAllEntries() -> [DictionaryEntry] {
        return entries
    }
    
    // Returns all entries to be studied today
    func getEntriesToStudy() -> [DictionaryEntry] {
        var studyEntries: [DictionaryEntry] = []
        for entry in entries {
            let status = entry.status!
            if status == Status.seen.rawValue {
                if Calendar.current.isDateInToday(entry.nextReviewDate ?? Date()) || (Date() > entry.nextReviewDate!) {
                    studyEntries.append(entry)
                }
            }
        }
        return studyEntries
    }
    
    // Filters through all entries given a keyword (both word and definition)
    func search(query: String) -> [DictionaryEntry] {
        return query == "" ? entries.sorted(by: { $0.word ?? "" < $1.word ?? "" }) : entries.filter {
            $0.word!.lowercased().contains(query.lowercased()) || $0.definition!.lowercased().contains(query.lowercased())
        }
    }
    
    // Saves changes to the managed object context
    func saveContext() {
        do {
            try context.save()
        } catch let error {
            print("An error occurred while saving changes to the managed object context: \(error.localizedDescription)")
        }
    }
    
    // Deletes all objects in the persistent store
    func resetContext() {
        for obj in context.registeredObjects {
            context.delete(obj)
        }
        saveContext()
    }
}
