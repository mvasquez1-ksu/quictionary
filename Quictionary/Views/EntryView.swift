//
//  EntryView.swift
//  Quictionary
//
//  Created by Marco Vasquez on 3/9/23.
//  View displaying all information of a selected dictionary entry

import SwiftUI
import Foundation


struct EntryView: View {
    // Presentation Mode
    @Environment(\.presentationMode) var presentationMode:
    Binding<PresentationMode>
    // Controller
    @EnvironmentObject var dictionaryController: DictionaryController
    // The selected dictionary entry
    private var selectedEntry: DictionaryEntry
    // The current selection of the status picker
    @State private var selection: Int = 1
    // The status of the selected entry
    @State private var status: String = ""
    
    init(passedEntry: DictionaryEntry) {
        self.selectedEntry = passedEntry
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(selectedEntry.word ?? "")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
            Text(selectedEntry.pronunciation ?? "")
                .font(.caption)
            Text(selectedEntry.type ?? "")
                .font(.caption)
            ZStack {
                VStack(alignment: .leading) {
                    Text("Translation")
                        .font(.caption2)
                    Text(selectedEntry.definition ?? "")
                        .font(.title2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .foregroundColor(.white)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.quicGreen)
                }
            }
            ZStack {
                VStack(alignment: .leading) {
                    Text("Example Sentences")
                        .font(.caption2)
                    ForEach(0..<selectedEntry.l1exampleSentences!.count, id: \.self) { index in
                        Text(selectedEntry.l1exampleSentences![index])
                            .font(.title2)
                        Text(selectedEntry.l2exampleSentences![index])
                            .italic()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .foregroundColor(.white)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.quicGreen)
                }
            }
            ZStack {
                VStack(alignment: .leading) {
                    Text("Review")
                        .font(.caption2)
                    Text("You last reviewed this card on \(selectedEntry.lastReviewed!.formatted(.dateTime.day().month(.wide).year()))")
                    Text("You will see this card again on \(selectedEntry.nextReviewDate!.formatted(.dateTime.day().month(.wide).year()))")
                    Text("Review Interval: \(selectedEntry.reviewInterval)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .foregroundColor(.white)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.quicGreen)
                }
            }
            ZStack {
                VStack(alignment: .leading) {
                    Text("Status")
                        .font(.caption2)
                    //Text(status)
                    switch (status) {
                    case "seen":
                        Text("You have seen this card and it will be considered in your daily reviews.")
                    case "unseen":
                        Text("You have not yet seen this card and it will not be considered in your daily reviews.")
                    case "excluded":
                        Text("You have seen this card but it will not be considered in your daily reviews.")
                    default:
                        Text("Status unknown.")
                    }
                    Picker("", selection: $selection) {
                        Text("Seen").tag(1 as Int)
                        Text("Not Yet Seen").tag(2 as Int)
                        Text("Excluded").tag(3 as Int)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .onChange(of: selection) { value in
                    switch (value) {
                    case 1:
                        dictionaryController.markAsSeen(entry: selectedEntry)
                    case 2:
                        dictionaryController.markAsUnseen(entry: selectedEntry)
                    case 3:
                        dictionaryController.markAsExcluded(entry: selectedEntry)
                    default:
                        print("Nothing happened")
                    }
                    status = selectedEntry.status!
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .foregroundColor(.white)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.quicGreen)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: StudyListSelectionView(passedDictionaryEntry: selectedEntry), label: {
                        Image(systemName: "note.text.badge.plus")
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: StudyView(controller: dictionaryController, entry: selectedEntry), label: {
                        Image(systemName: "book")
                    })
                }
            }
            .onAppear {
                status = selectedEntry.status!
                if (status == Status.unseen.rawValue) {
                    selection = 2
                }
                else if (status == Status.excluded.rawValue) {
                    selection = 3
                }
                else {
                    selection = 1
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .navigationTitle(selectedEntry.word!)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView(passedEntry: DictionaryEntry())
    }
}
