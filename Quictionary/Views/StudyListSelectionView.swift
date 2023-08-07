//
//  StudyListSelectionView.swift
//  Quictionary
//
//  Created by Marco Vasquez on 3/20/23.
//  View allowing user to select a study list to add a dictionary entry to

import SwiftUI

struct StudyListSelectionView: View {
    // Presentation mode
    @Environment(\.presentationMode) var presentationMode:
    Binding<PresentationMode>
    // Controller
    @EnvironmentObject var dictionaryController: DictionaryController
    // All study lists
    @State private var studyLists = [StudyList]()
    // The entry to be added to a study list
    private var selectedEntry: DictionaryEntry
    
    init(passedDictionaryEntry: DictionaryEntry) {
        selectedEntry = passedDictionaryEntry

    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    List {
                        ForEach(studyLists, id: \.self) { studyList in
                            StudyListCell(passedStudyList: studyList).onTapGesture {
                                dictionaryController.addToStudyList(entry: selectedEntry, studyList: studyList)
                                self.presentationMode.wrappedValue.dismiss()
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .disabled(studyList.entries!.contains(selectedEntry))
                        }
                    }
                }
            }
            .navigationTitle("Add to Study List")
            .onAppear() {
                studyLists = dictionaryController.getStudyLists()
            }
        }
    }
}

struct StudyListSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        StudyListSelectionView(passedDictionaryEntry: DictionaryEntry())
    }
}
