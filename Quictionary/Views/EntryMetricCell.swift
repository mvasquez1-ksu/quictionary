//
//  EntryMetricCell.swift
//  Quictionary
//
//  Created by Marco Vasquez on 4/26/23.
//  View displaying entry metrics (## seen/unseen/excluded) as a cell

import SwiftUI

struct EntryMetricCell: View {
    // Controller
    @EnvironmentObject var dictionaryController: DictionaryController
    // Selected list of dictionary entries
    private var selectedEntries: [DictionaryEntry]
    // Number seen
    @State private var seen = 0
    // Number unseen
    @State private var unseen = 0
    // Number excluded
    @State private var excluded = 0
    
    init(passedEntries: [DictionaryEntry]) {
        selectedEntries = passedEntries
    }
    
    var body: some View {
        HStack {
            Text("\(seen) seen")
            Text("\(unseen) not yet seen")
            Text("\(excluded) excluded")
        }
        .onAppear {
            let metrics = dictionaryController.getMetrics(entries: selectedEntries)
            seen = metrics[0]
            unseen = metrics[1]
            excluded = metrics[2]
        }
        .padding()
        .foregroundColor(.white)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.quicGreen)
        }
    }
}

struct EntryMetricCell_Previews: PreviewProvider {
    static var previews: some View {
        EntryMetricCell(passedEntries: [DictionaryEntry]())
    }
}
