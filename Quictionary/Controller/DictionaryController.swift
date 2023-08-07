//
//  DictionaryController.swift
//  Quictionary
//
//  Created by Marco Vasquez on 2/21/23.
//  Acts as controller layer of application

import Foundation

class DictionaryController : ObservableObject {
    // The dictionary model that this class will manipulate
    private let model: DictionaryModel
    
    // The list of dictionary entries currently being studied
    private var activeEntries = [DictionaryEntry]()
    
    init(model: DictionaryModel) {
        self.model = model
    }
    
    // Returns all study lists
    func getStudyLists() -> [StudyList] {
        model.getStudyLists()
    }
    
    // Returns the entries to be studied today
    func getCardsToStudy() -> [DictionaryEntry] {
        model.getEntriesToStudy()
    }
    
    // Returns all entries
    func getAllEntries() -> [DictionaryEntry] {
        model.getAllEntries()
    }
    
    // Returns all entries from a given study list
    func getEntries(studyList: StudyList) -> [DictionaryEntry] {
        return Array(studyList.entries as? Set<DictionaryEntry> ?? []).sorted(by: { $0.word ?? "" < $1.word ?? "" })
    }
    
    // Creates a new study list with a given title
    func createStudyList(title: String) {
        model.createStudyList(title: title)
        model.saveContext()
    }
    
    // Deletes the given study list
    func deleteStudyList(studyList: StudyList) {
        model.deleteStudyList(studyList)
        model.saveContext()
    }
    
    // Renames a study list with a given title
    func renameStudyList(studyList: StudyList, title: String) {
        studyList.title = title
        model.saveContext()
    }
    
    // Adds an entry to a study list
    func addToStudyList(entry: DictionaryEntry, studyList: StudyList) {
        model.addEntryToStudyList(entry: entry, studyList: studyList)
        model.saveContext()
    }
    
    
    // Removes an entry from a study list
    func removeFromStudyList(entry: DictionaryEntry, studyList: StudyList) {
        model.removeEntryFromStudyList(entry: entry, studyList: studyList)
        model.saveContext()
    }
    
    // Indicates that the given entry was remembered during review
    func rememberCard(entry: DictionaryEntry) {
        entry.consecutiveCount += 1
        if (entry.consecutiveCount >= 3) {
            assignSRS(entry: entry)
        }
        markAsSeen(entry: entry)
        model.saveContext()
    }
    
    // Indicates that the given entry was forgotten during review
    func forgetCard(entry: DictionaryEntry) {
        if (entry.consecutiveCount == 4) {
            entry.consecutiveCount -= 2
        }
        else if (entry.consecutiveCount != 0){
            entry.consecutiveCount -= 1
        }
        entry.forgetCount += 1
        markAsSeen(entry: entry)
        model.saveContext()
    }
    
    // Assigns review interval and difficulty of an entry based on review performance
    func assignSRS(entry: DictionaryEntry) {
        let performance = calculatePerformance(forgetCount: entry.forgetCount)
        let r = entry.reviewInterval
        var e = entry.difficulty
        e += (1.0/17.0) * (8.0 - 9.0 * performance)
        var reviewMultiplier: Float
        var percentOverdue: Float
        let lastReviewDate = entry.nextReviewDate ?? Date()
        var daysSinceLastReview: Float
        if (Date() - 1 > lastReviewDate) {
            daysSinceLastReview = Float(Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: lastReviewDate), to: Calendar.current.startOfDay(for: Date())).day!)
        }
        else {
            daysSinceLastReview = r
        }
        if (performance > 0.6) {
            percentOverdue = min(2, max((daysSinceLastReview / r), 1))
            entry.difficulty = min(max(entry.difficulty + percentOverdue + e, 0.0), 1.0)
            let difficultyWeight = 3 - 1.7 * entry.difficulty
            reviewMultiplier = 1.0 + (difficultyWeight - 1.0) * percentOverdue * Float.random(in: 0.95..<1.06)
            entry.consecutiveCount = 4
        }
        else {
            percentOverdue = 1.0
            entry.difficulty = min(max(entry.difficulty + percentOverdue + e, 0.0), 1.0)
            reviewMultiplier = 1.0/(1.0 + 3.0 * entry.difficulty)
            entry.consecutiveCount = 0
        }
        entry.reviewInterval *= reviewMultiplier
        entry.forgetCount = 0
        model.updateReviewDate(entry: entry)
        model.saveContext()
    }
    
    // Calculates the performance of a reviewed entry based on times forgotten/remembered
    func calculatePerformance(forgetCount: Int64) -> Float {
        if (forgetCount >= 5) {
            return 0.0
        }
        else if (forgetCount == 0) {
            return 1.0
        }
        else {
            return max(1.0 - (Float(forgetCount) * 0.2), 0)
        }
    }
    
    // Marks entry as seen
    func markAsSeen(entry: DictionaryEntry) {
        model.setEntryStatus(entry: entry, status: "seen")
        model.saveContext()
    }
    
    // Marks entry as unseen
    func markAsUnseen(entry: DictionaryEntry) {
        model.setEntryStatus(entry: entry, status: "unseen")
        model.saveContext()
    }

    // Marks entry as excluded
    func markAsExcluded(entry: DictionaryEntry) {
        model.setEntryStatus(entry: entry, status: "excluded")
        model.saveContext()
    }
    
    // Filters through all entries given a query
    func search(query: String) -> [DictionaryEntry] {
        model.search(query: query)
    }
    
    // Sets active entries
    func setActiveEntries(entries: [DictionaryEntry]) {
        self.activeEntries = [DictionaryEntry]()
        self.activeEntries = entries
    }
    
    // Sets active entries given a single entry (Used for studying from any one entry's EntryView)
    func setActiveEntry(entry: DictionaryEntry) {
        self.activeEntries = [DictionaryEntry]()
        activeEntries.insert(entry, at: 0)
    }
    
    // Cycles the active entries during the review process (Entries inserted at the beginning if SRS not ready to be assigned)
    func cycleActiveEntries() {
        if activeEntries.count > 0 {
            let entry = self.activeEntries.removeLast()
            let nextDate = entry.nextReviewDate ?? Date()
            if Calendar.current.isDateInToday(nextDate) || Date() > nextDate {
                activeEntries.insert(entry, at: 0)
            }
        }
    }
    
    // Returns the active entries
    func getActiveEntries() -> [DictionaryEntry] {
        return self.activeEntries
    }
    
    // Returns the number of seen, unseen, and excluded entries given a list of dictionary entries
    func getMetrics(entries: [DictionaryEntry]) -> [Int] {
        var seen = 0
        var unseen = 0
        var excluded = 0
        for entry in entries {
            if (entry.status == Status.seen.rawValue) {
                seen += 1
            }
            else if (entry.status == Status.unseen.rawValue) {
                unseen += 1
            }
            else if (entry.status == Status.excluded.rawValue) {
                excluded += 1
            }
        }
        return [seen, unseen, excluded]
    }
        
}
