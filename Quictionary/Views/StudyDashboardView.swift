//
//  StudyDashboardView.swift
//  Quictionary
//
//  Created by Marco Vasquez on 3/28/23.
//  View displaying cards to be studied today

import SwiftUI

struct StudyDashboardView: View {
    // Controller
    @EnvironmentObject var dictionaryController: DictionaryController
    // Entries to be studied today
    @State var entries = [DictionaryEntry]()
    
    var body: some View {
        NavigationView {
            VStack {
                EntryMetricCell(passedEntries: dictionaryController.getAllEntries())
                Text("You have \(entries.count) cards to study today.")
                NavigationLink(destination: StudyView(controller: dictionaryController, entries: self.entries), label: {
                    Text("Study")
                }).disabled(entries.count == 0)
            }
            .navigationTitle("Study")
            .onAppear {
                entries = dictionaryController.getCardsToStudy()
            }
        }
    }
}

struct StudyDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        StudyDashboardView().environmentObject(DictionaryController(model: DictionaryModel(context: PersistenceController.preview.container.viewContext)))
    }
}
