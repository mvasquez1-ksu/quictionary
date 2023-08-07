//
//  ContentView.swift
//  Quictionary
//
//  Created by Marco Vasquez on 2/3/23.
//  View displaying all study lists

import SwiftUI
import CoreData

struct BrowseListsView: View {
    // Controller
    @EnvironmentObject var dictionaryController: DictionaryController
    
    // List of all study lists
    private var studyLists: [StudyList] {
        return dictionaryController.getStudyLists()
    }
    // Univerally Unique ID used to force a view reload
    @State private var refreshID = UUID()

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    List {
                        ForEach(studyLists, id: \.self) { studyList in
                            StudyListCell(passedStudyList: studyList)
                                .background(NavigationLink("", destination: StudyListView(selectedStudyList: studyList)).opacity(0))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)

                        }
                        .onDelete(perform: deleteItems)
                    }
                    .id(refreshID)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: StudyListEditView(passedStudyList: nil), label: {
                                Image(systemName: "plus")
                            })
                        }
                    }
                }
            }
            .navigationTitle("Study Lists")
            .onAppear {
                    refreshStudyLists()
                }
        }
    }

    // Handles deleting a study list
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.forEach {
                index in
                let studyList = studyLists[index]
                dictionaryController.deleteStudyList(studyList: studyList)
            }
        }
        refreshStudyLists()
    }
    
    // Refreshes the list of study lists when changes are made
    private func refreshStudyLists() {
        refreshID = UUID()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseListsView()
            .environmentObject(DictionaryController(model: DictionaryModel(context: PersistenceController.preview.container.viewContext)))
    }
}
