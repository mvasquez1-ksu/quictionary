//
//  StudyView.swift
//  Quictionary
//
//  Created by Marco Vasquez on 3/28/23.
//  View displaying dictionary entries as cards

import SwiftUI

struct StudyView: View {
    // Presentation Mode
    @Environment(\.presentationMode) var presentationMode:
    Binding<PresentationMode>
    // Controller
    private var dictionaryController: DictionaryController
    // Dictionary entries
    private var entries: [DictionaryEntry] {
        return dictionaryController.getActiveEntries().suffix(5)
    }
    // Universally Unique ID to force view changes
    @State private var refreshID = UUID()
    
    init(controller: DictionaryController, entries: [DictionaryEntry]) {
        self.dictionaryController = controller
        dictionaryController.setActiveEntries(entries: entries)
    }
    
    init(controller: DictionaryController, entry: DictionaryEntry) {
        self.dictionaryController = controller
        dictionaryController.setActiveEntry(entry: entry)
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<entries.count, id: \.self) { index in
                        StudyCard(dictionaryEntry: entries[index]) {
                            withAnimation {
                                dictionaryController.cycleActiveEntries()
                                if entries.count == 0 {
                                    presentationMode.wrappedValue.dismiss()
                                }
                                refreshEntries()
                            }
                        }
                        .frame(width: getCardWidth(geometry, id: index), height: 500)
                        .offset(x: 0, y: getCardOffset(geometry, id: index))
                    }
                }.id(refreshID)
            }
        }
        .navigationTitle("Study")
    }
    
    // UI helper function taken from Better Programming's Tinder-Style Swipeable Card View tutorial
    func getCardOffset(_ geometry: GeometryProxy, id: Int) -> CGFloat {
        return CGFloat(entries.count - 1 - id) * 10
    }
    
    // UI helper function taken from Better Programming's Tinder-Style Swipeable Card View tutorial
    func getCardWidth(_ geometry: GeometryProxy, id: Int) -> CGFloat {
        let offset = CGFloat(entries.count - 1 - id) * 10
        return geometry.size.width - offset
    }
    
    // Refreshes entries when changes are made
    private func refreshEntries() {
        refreshID = UUID()
    }
}

struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        StudyView(controller: DictionaryController(model: DictionaryModel(context: PersistenceController.preview.container.viewContext)),entries: [DictionaryEntry]())
    }
}
