//
//  StudyListCell.swift
//  Quictionary
//
//  Created by Marco Vasquez on 4/25/23.
//  View displaying study list as a cell (used to list study lists)

import SwiftUI

struct StudyListCell: View {
    // Passed study list
    @ObservedObject var passedStudyList: StudyList
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.quicGreen)
                //.frame(width: 350.0, height: 400.0)
            VStack(alignment: .leading, spacing: 8) {
                Text(passedStudyList.title ?? "")
                    .fontWeight(.bold)
                Text("\(passedStudyList.count) entries")
                    .font(.caption)
            }.foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

struct StudyListCell_Previews: PreviewProvider {
    static var previews: some View {
        StudyListCell(passedStudyList: StudyList())
    }
}
