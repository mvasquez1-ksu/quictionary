//
//  StudyListView.swift
//  Quictionary
//
//  Created by Marco Vasquez on 2/27/23.
//  View displaying all entries in a study list

import SwiftUI

struct StudyListView: View {
    // Presentation Mode
    @Environment(\.presentationMode) var presentationMode:
    Binding<PresentationMode>
    // Controller
    @EnvironmentObject var dictionaryController: DictionaryController
    // The selected study list
    @ObservedObject var selectedStudyList: StudyList
    // The list of entries in the selected study list
    private var entries: [DictionaryEntry] {
        return dictionaryController.getEntries(studyList: selectedStudyList)
    }
    
    var body: some View {
        VStack {
            ZStack {
                List {
                    EntryMetricCell(passedEntries: entries)
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    ForEach(entries) { (entry: DictionaryEntry) in
                        EntryCell(passedEntry: entry)
                            .background(NavigationLink("", destination: EntryView(passedEntry: entry)).opacity(0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: StudyListEditView(passedStudyList: selectedStudyList)) {
                            Image(systemName: "pencil")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: StudyView(controller: dictionaryController, entries: entries)) {
                            Image(systemName: "book")
                        }
                    }
                }
            }
        }
        .navigationTitle(selectedStudyList.title ?? "")
    }
    
    // Handles removing entries from the selected study list
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.forEach {
                index in
                let entry = entries[index]
                dictionaryController.removeFromStudyList(entry: entry, studyList: selectedStudyList)
            }
        }
    }
}

struct StudyListView_Previews: PreviewProvider {
    static var previews: some View {
        StudyListView(selectedStudyList: StudyList())
    }
}
