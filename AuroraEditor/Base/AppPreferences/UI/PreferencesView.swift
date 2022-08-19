//
//  PreferencesView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/18.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {

    @StateObject
    var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.setting) { item in
                    NavigationLink(destination: settingContentView,
                                   tag: item.id,
                                   selection: $viewModel.selectedId) {
                        HStack {
                            Image(nsImage: item.image)
                                .imageScale(.small)
                            Text(item.name)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            Text("No selection")
        }
        .frame(width: 760, height: 500)
    }

    var settingContentView: some View {
        ScrollView {
            if viewModel.selectedId == viewModel.setting[0].id {
                GeneralPreferencesView()
            } else if viewModel.selectedId == viewModel.setting[1].id {
                PreferenceAccountsView()
            } else if viewModel.selectedId == viewModel.setting[2].id {
                PreferencesPlaceholderView()
            } else if viewModel.selectedId == viewModel.setting[3].id {
                PreferencesPlaceholderView()
            } else if viewModel.selectedId == viewModel.setting[4].id {
                ThemePreferencesView()
            } else if viewModel.selectedId == viewModel.setting[5].id {
                TextEditingPreferencesView()
            } else if viewModel.selectedId == viewModel.setting[6].id {
                TerminalPreferencesView()
            } else if viewModel.selectedId == viewModel.setting[7].id {
                PreferencesPlaceholderView()
            } else if viewModel.selectedId == viewModel.setting[8].id {
                PreferenceSourceControlView()
            } else if viewModel.selectedId == viewModel.setting[9].id {
                PreferencesPlaceholderView()
            } else if viewModel.selectedId == viewModel.setting[10].id {
                LocationsPreferencesView()
            } else if viewModel.selectedId == viewModel.setting[11].id {
                PreferencesPlaceholderView()
            }
        }
    }
}

struct SettingItem: Identifiable {
    let id = UUID().uuidString
    let name: String
    let image: NSImage
}

final class ViewModel: ObservableObject {

    init(setting: [SettingItem] = ViewModel.settingItems) {
        self.setting = setting
        self.selectedId = setting[0].id
    }

    @Published
    var setting: [SettingItem]
    @Published
    var selectedId: String?

    static let settingItems = [
        SettingItem(name: "General",
                    image: NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)!),
        SettingItem(name: "Accounts",
                    image: NSImage(systemSymbolName: "at", accessibilityDescription: nil)!),
        SettingItem(name: "Behaviors",
                    image: NSImage(systemSymbolName: "flowchart", accessibilityDescription: nil)!),
        SettingItem(name: "Navigation",
                    image: NSImage(systemSymbolName: "arrow.triangle.turn.up.right.diamond",
                                   accessibilityDescription: nil)!),
        SettingItem(name: "Themes",
                    image: NSImage(systemSymbolName: "paintbrush", accessibilityDescription: nil)!),
        SettingItem(name: "Text Editing",
                    image: NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: nil)!),
        SettingItem(name: "Terminal",
                    image: NSImage(systemSymbolName: "terminal", accessibilityDescription: nil)!),
        SettingItem(name: "Key Bindings",
                    image: NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil)!),
        SettingItem(name: "Source Control",
                    image: NSImage.vault),
        SettingItem(name: "Components",
                    image: NSImage(systemSymbolName: "puzzlepiece", accessibilityDescription: nil)!),
        SettingItem(name: "Locations",
                    image: NSImage(systemSymbolName: "externaldrive", accessibilityDescription: nil)!),
        SettingItem(name: "Advanced",
                    image: NSImage(systemSymbolName: "gearshape.2", accessibilityDescription: nil)!)
    ]
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
