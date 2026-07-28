//
//  SettingsView.swift
//  Mihome Proxy
//
//  Created by NodePassProject on 5/2/26.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var tunnel = TunnelManager.shared

    var body: some View {
        NavigationView {
            Form {
                Section("VPN") {
                    Toggle(isOn: $appState.alwaysOnEnabled) {
                        Label("Always On", systemImage: "bolt")
                    }
                    .disabled(tunnel.pendingReconnect)
                    NavigationLink {
                        TunnelSettingsView()
                    } label: {
                        Label("Tunnel", systemImage: "shield")
                    }
                }

                Section("Network") {
                    NavigationLink {
                        DNSSettingsView()
                    } label: {
                        Label("DNS", systemImage: "network")
                    }
                }

                Section("IO") {
                    NavigationLink {
                        ResourcesView()
                    } label: {
                        Label("Resources", systemImage: "folder")
                    }
                }
                
                Section("About") {
                    NavigationLink {
                        AcknowledgementView()
                    } label: {
                        Label("Acknowledgements", systemImage: "heart")
                    }
                }
            }
            .navigationTitle("Settings")
            .onChange(of: appState.alwaysOnEnabled) { newValue in
                Task { await tunnel.applyAlwaysOn(newValue) }
            }
        }
        .navigationViewStyle(.stack)
    }
}
