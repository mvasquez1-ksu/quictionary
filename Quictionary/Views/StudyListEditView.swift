//
//  StudyListEditView.swift
//  Quictionary
//
//  Created by Marco Vasquez on 2/23/23.
//  View for creating/editing a study list

import SwiftUI

struct StudyListEditView: View {
    // Presentation Mode
    @Environment(\.presentationMode) var presentationMode:
    Binding<PresentationMode>
    // Controller
    @EnvironmentObject var dictionaryController: DictionaryController
    // The selected study list
    @State var selectedStudyList: StudyList?
    // The title of the selected study list
    @State var title: String
    
    // Binds the title to the selected study list or an empty string if creating a new study list
    init(passedStudyList: StudyList?) {
        if let studyList = passedStudyList {
            _selectedStudyList = State(initialValue: studyList)
            _title = State(initialValue: studyList.title ?? "")
        }
        else {
            _title = State(initialValue: "")
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Study List")) {
                TextField("Study List Title", text: $title)
            }
            Section(header: Text("Save")) {
                Button("Save", action: saveAction)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    // Handles saving changes
    private func saveAction() {
        withAnimation {
            if selectedStudyList == nil {
                dictionaryController.createStudyList(title: title)
            }
            else {
                dictionaryController.renameStudyList(studyList: selectedStudyList ?? StudyList(), title: title)
            }
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct StudyListEditView_Previews: PreviewProvider {
    static var previews: some View {
        StudyListEditView(passedStudyList: StudyList())
            .environmentObject(DictionaryController(model: DictionaryModel(context: PersistenceController().container.viewContext)))
    }
}
