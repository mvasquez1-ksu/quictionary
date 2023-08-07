//
//  EntrySearchView.swift
//  Quictionary
//
//  Created by Marco Vasquez on 3/1/23.
//  View that displays and filters entries

import SwiftUI

struct EntrySearchView: View {
    // Controller
    @EnvironmentObject var dictionaryController: DictionaryController
    // The filter query
    @State var query: String = ""
    // The dictionary entries currently being displayed
    var entries: [DictionaryEntry] {
        return dictionaryController.search(query: query)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(entries, id: \.self) { (entry: DictionaryEntry) in
                        EntryCell(passedEntry: entry)
                            .background(NavigationLink("", destination: EntryView(passedEntry: entry)).opacity(0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)

                    }
                }
            }
        }
        .searchable(text: $query)
    }
}

struct EntrySearchView_Previews: PreviewProvider {
    static var previews: some View {
        EntrySearchView()
    }
}
