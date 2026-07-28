//
//  ResourcesView.swift
//  Everywhere
//
//  Created by NodePassProject on 5/2/26.
//

import SwiftUI

struct ResourcesView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink {
                    DirectoryBrowserView(url: ResourcesStore.directory, title: "mihomo")
                } label: {
                    Label("mihomo", systemImage: "folder")
                }
            }
        }
        .navigationTitle("Resources")
        .navigationBarTitleDisplayMode(.inline)
    }
}
