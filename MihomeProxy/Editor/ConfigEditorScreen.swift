//
//  ConfigEditorScreen.swift
//  Mihome Proxy
//
//  Created by NodePassProject on 5/2/26.
//

import SwiftUI

struct ConfigEditorScreen: View {
    @ObservedObject var configuration: Configuration
    @ObservedObject private var store = ConfigurationStore.shared
    @State private var draft: String = ""

    var body: some View {
        ConfigEditorView(text: draftBinding)
            .id(configuration.id)
            .navigationTitle(configuration.name.isEmpty ? "Configuration" : configuration.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            draft = CoreType.defaultConfig
                            store.update(configuration, content: draft)
                        } label: {
                            Label("Reset to default", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis")
                    }
                }
            }
            .onAppear { draft = configuration.content }
    }

    private var draftBinding: Binding<String> {
        Binding(
            get: { draft },
            set: { newValue in
                draft = newValue
                store.update(configuration, content: newValue)
            }
        )
    }
}
