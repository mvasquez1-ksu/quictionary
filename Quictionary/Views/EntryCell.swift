//
//  EntryCell.swift
//  Quictionary
//
//  Created by Marco Vasquez on 4/24/23.
//  View displaying dictionary entry as a cell (used to list dictionary entries)

import SwiftUI

struct EntryCell: View {
    // Passed dictionary entry
    @ObservedObject var passedEntry: DictionaryEntry
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.quicGreen)
            VStack(alignment: .leading, spacing: 8) {
                Text(passedEntry.word ?? "")
                    .fontWeight(.bold)
                Text(passedEntry.definition ?? "")
                    .font(.caption)
            }.foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
}

struct EntryCell_Previews: PreviewProvider {
    static var previews: some View {
        EntryCell(passedEntry: DictionaryEntry(context: PersistenceController.preview.container.viewContext))
    }
}
