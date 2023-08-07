//
//  QuictionaryTests.swift
//  QuictionaryTests
//
//  Created by Marco Vasquez on 2/3/23.
//  Unit tests for Quictionary

import CoreData
import XCTest
@testable import Quictionary

final class QuictionaryTests: XCTestCase {
    var context: NSManagedObjectContext!
    var model: DictionaryModel!
    var controller: DictionaryController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        context = PersistenceController.shared.container.viewContext
        model = DictionaryModel(context: context)
        controller = DictionaryController(model: model)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        context = nil
        model = nil
        controller = nil
    }
    
    func testStudyListAdded() throws {
        model.createStudyList(title: "Test Study List")
        XCTAssert(model.getStudyLists().contains(where: { $0.title == "Test Study List"}))
    }
    
    func testStudyListRenamed() throws {
        model.createStudyList(title: "Test Study List")
        let l1 = model.getStudyLists().first(where: { $0.title == "Test Study List"})
        controller.renameStudyList(studyList: l1!, title: "Renamed Study List")
        XCTAssert(l1?.title == "Renamed Study List")
    }
    
    func testStudyListDeleted() throws {
        model.createStudyList(title: "Test Study List")
        let l1 = model.getStudyLists().first(where: { $0.title == "Test Study List"})
        model.deleteStudyList(l1!)
        XCTAssert(!model.getStudyLists().contains(l1!))
    }
    
    func testEntryAddedToStudyList() throws {
        model.createStudyList(title: "Test Study List")
        let l1 = model.getStudyLists().first(where: { $0.title == "Test Study List"})
        let e1 = DictionaryEntry(context: context)
        e1.status = Status.seen.rawValue
        e1.word = "Avion"
        e1.definition = "Airplane"
        e1.lastReviewed = Date()
        e1.nextReviewDate = Date()
        e1.reviewInterval = 0.5
        model.addEntryToStudyList(entry: e1, studyList: l1!)
        XCTAssert(l1!.entries!.contains(e1))
    }
    
    func testEntryRemovedFromStudyList() throws {
        model.createStudyList(title: "Test Study List")
        let l1 = model.getStudyLists().first(where: { $0.title == "Test Study List"})
        let e1 = DictionaryEntry(context: context)
        e1.status = Status.seen.rawValue
        e1.word = "Avion"
        e1.definition = "Airplane"
        e1.lastReviewed = Date()
        e1.nextReviewDate = Date()
        e1.reviewInterval = 0.5
        model.removeEntryFromStudyList(entry: e1, studyList: l1!)
        XCTAssert(!l1!.entries!.contains(e1))
    }
    
    func testEntryReviewDateAssigned() throws {
        let e1 = DictionaryEntry(context: context)
        e1.status = Status.seen.rawValue
        e1.word = "Avion"
        e1.definition = "Airplane"
        e1.lastReviewed = Date()
        e1.nextReviewDate = Date()
        let oldReviewDate = e1.nextReviewDate
        e1.reviewInterval = 0.5
        for _ in 0..<3 {
            controller.rememberCard(entry: e1)
        }
        XCTAssert(e1.nextReviewDate != oldReviewDate)
    }
    
    func testEntryReviewDateInFuture() throws {
        let e1 = DictionaryEntry(context: context)
        e1.status = Status.seen.rawValue
        e1.word = "Avion"
        e1.definition = "Airplane"
        e1.lastReviewed = Date()
        e1.nextReviewDate = Date()
        let oldReviewDate = e1.nextReviewDate!
        e1.reviewInterval = 0.5
        for _ in 0..<3 {
            controller.rememberCard(entry: e1)
        }
        XCTAssert(e1.nextReviewDate!.timeIntervalSince(oldReviewDate) > 0)
    }
    
    func testOnlySeenEntriesConsidered() throws {
        let e1 = DictionaryEntry(context: context)
        let e2 = DictionaryEntry(context: context)
        let e3 = DictionaryEntry(context: context)
        e1.status = Status.seen.rawValue
        e1.word = "Avion"
        e1.definition = "Airplane"
        e1.lastReviewed = Date()
        e1.nextReviewDate = Date()
        e1.reviewInterval = 0.5
        e2.status = Status.unseen.rawValue
        e2.word = "Test Word 1"
        e2.definition = "Test Definition 1"
        e2.lastReviewed = Date()
        e2.nextReviewDate = Date()
        e2.reviewInterval = 0.5
        e3.status = Status.excluded.rawValue
        e3.word = "Test Word 2"
        e3.definition = "Test Definition 2"
        e3.lastReviewed = Date()
        e3.nextReviewDate = Date()
        e3.reviewInterval = 0.5
        XCTAssert(!model.getEntriesToStudy().contains(e2) && !model.getEntriesToStudy().contains(e3))
    }
    
    func testReviewIntervalDecreased() throws {
        let e1 = DictionaryEntry(context: context)
        e1.status = Status.seen.rawValue
        e1.word = "Avion"
        e1.definition = "Airplane"
        e1.lastReviewed = Date()
        e1.nextReviewDate = Date()
        e1.reviewInterval = 0.5
        let oldReviewInterval = e1.reviewInterval
        model.addEntry(entry: e1)
        for _ in 0..<3 {
            controller.forgetCard(entry: e1)
        }
        for _ in 0..<3 {
            controller.rememberCard(entry: e1)
        }
        XCTAssert(e1.reviewInterval < oldReviewInterval)
    }
    
    func testReviewIntervalIncreased() throws {
        let e1 = DictionaryEntry(context: context)
        e1.status = Status.seen.rawValue
        e1.word = "Avion"
        e1.definition = "Airplane"
        e1.lastReviewed = Date()
        e1.nextReviewDate = Date()
        e1.reviewInterval = 0.5
        let oldReviewInterval = e1.reviewInterval
        model.addEntry(entry: e1)
        for _ in 0..<3 {
            controller.rememberCard(entry: e1)
        }
        XCTAssert(e1.reviewInterval > oldReviewInterval)
    }
    
    func testReviewDateCorrectAdjustment() throws {
        let e1 = DictionaryEntry(context: context)
        let e2 = DictionaryEntry(context: context)
        let e3 = DictionaryEntry(context: context)
        e1.status = Status.seen.rawValue
        e1.word = "Avion"
        e1.definition = "Airplane"
        e1.lastReviewed = Date()
        e1.nextReviewDate = Date()
        e1.reviewInterval = 0.5
        e2.status = Status.seen.rawValue
        e2.word = "Test Word 1"
        e2.definition = "Test Definition 1"
        e2.lastReviewed = Date()
        e2.nextReviewDate = Date()
        e2.reviewInterval = 0.5
        e3.status = Status.seen.rawValue
        e3.word = "Test Word 2"
        e3.definition = "Test Definition 2"
        e3.lastReviewed = Date()
        e3.nextReviewDate = Date()
        e3.reviewInterval = 0.5
        // First card forgotten five times then remembered three times
        for _ in 0..<5 {
            controller.forgetCard(entry: e1)
        }
        for _ in 0..<3 {
            controller.rememberCard(entry: e1)
        }
        // Second card forgotten two times then remembered three times
        controller.forgetCard(entry: e2)
        controller.forgetCard(entry: e2)
        for _ in 0..<3 {
            controller.rememberCard(entry: e2)
        }
        // Third card forgotten zero times and remembered three times
        for _ in 0..<3 {
            controller.rememberCard(entry: e3)
        }
        let e1nextDate = e1.nextReviewDate!
        let e2nextDate = e2.nextReviewDate!
        let e3nextDate = e3.nextReviewDate!
        // Assert review dates are in this order: e1 < e2 < e3
        XCTAssert((e1nextDate.timeIntervalSince(e2nextDate) < 0) && (e2nextDate.timeIntervalSince(e3nextDate) < 0))
    }
    
    func testOverdueEntriesConsidered() throws {
        let e1 = DictionaryEntry(context: context)
        e1.status = Status.seen.rawValue
        e1.word = "Avion"
        e1.definition = "Airplane"
        e1.lastReviewed = Date()
        e1.nextReviewDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        e1.reviewInterval = 0.5
        e1.status = Status.seen.rawValue
        model.addEntry(entry: e1)
        XCTAssert(model.getEntriesToStudy().contains(e1))
    }
    
    func testOverdueEntriesReviewInterval() throws {
        let e1 = DictionaryEntry(context: context)
        e1.status = Status.seen.rawValue
        e1.word = "Avion"
        e1.definition = "Airplane"
        e1.lastReviewed = Date()
        e1.nextReviewDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        e1.reviewInterval = 0.5
        e1.status = Status.seen.rawValue
        let e2 = DictionaryEntry(context: context)
        e2.status = Status.seen.rawValue
        e2.word = "Airplane"
        e2.definition = "Avion"
        e2.lastReviewed = Date()
        e2.nextReviewDate = Date()
        e2.reviewInterval = 0.5
        e2.status = Status.seen.rawValue
        model.addEntry(entry: e1)
        model.addEntry(entry: e2)
        // Forget and remember the cards the same amount of time
        controller.forgetCard(entry: e1)
        controller.forgetCard(entry: e2)
        for _ in 0..<3 {
            controller.rememberCard(entry: e1)
            controller.rememberCard(entry: e2)
        }
        let e1nextDate = e1.nextReviewDate!
        let e2nextDate = e2.nextReviewDate!
        // Assert that the overdue card will be given a bonus if remembered
        XCTAssert(e1nextDate.timeIntervalSince(e2nextDate) > 0)
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
