//
//  TabBarView.swift
//  Quictionary
//
//  Created by Marco Vasquez on 3/1/23.
//  View allowing for Tab Bar navigation

import SwiftUI

struct TabBarView: View {
    // Controller
    @EnvironmentObject var dictionaryController: DictionaryController
    // Current tab selection (defaults to search view)
    @State private var selection = 1
    
    var body: some View {
        TabView(selection: $selection) {
            StudyDashboardView()
                .tabItem {
                    Image(systemName: "chart.dots.scatter")
                    Text("Study")
                }
                .tag(2)
            
            EntrySearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)
            
            BrowseListsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Study Lists")
                }
                .tag(0)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
