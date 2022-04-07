//
//  OutlineViewController.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 07.04.22.
//

import SwiftUI
import WorkspaceClient
import AppPreferences

/// A `NSViewController` that handles the **ProjectNavigator** in the **NavigatorSideabr**.
///
/// Adds a ``outlineView`` inside a ``scrollView`` which shows the folder structure of the
/// currently open project.
class OutlineViewController: NSViewController {

    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!

    var content: [WorkspaceClient.FileItem] = []

    var workspace: WorkspaceDocument?

    var iconColor: AppPreferences.FileIconStyle = .color

    /// Setup the ``scrollView`` and ``outlineView``
    override func loadView() {
        self.scrollView = NSScrollView()
        self.view = scrollView

        self.outlineView = NSOutlineView()
        self.outlineView.delegate = self
        self.outlineView.dataSource = self
        self.outlineView.headerView = nil
        self.outlineView.menu = OutlineMenu()
        self.outlineView.menu?.delegate = self

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        self.scrollView.documentView = outlineView
        self.scrollView.contentView.automaticallyAdjustsContentInsets = false
        self.scrollView.contentView.contentInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
        reloadContent()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    /// Updates the selection of the ``outlineView`` whenever it changes.
    ///
    /// Most importantly when the `id` changes from an external view.
    func updateSelection() {
        guard let itemID = workspace?.selectionState.selectedId,
              let item = try? workspace?.workspaceClient?.getFileItem(itemID) else { return }

        let row = outlineView.row(forItem: item)
        if row == -1 {
            outlineView.deselectRow(outlineView.selectedRow)
        }
        outlineView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
    }

    /// Get the folder structure and store it into ``content``.
    ///
    /// Also creates a top level item "root" which represents the projects root directory and automatically expands it.
    private func reloadContent() {
        guard let folderURL = workspace?.workspaceClient?.folderURL() else { return }
        let children = workspace?.selectionState.fileItems.sortItems(foldersOnTop: true)
        let root = WorkspaceClient.FileItem(url: folderURL, children: children)
        self.content = [root]
        outlineView.reloadData()
        guard let item = outlineView.item(atRow: 0) else { return }
        outlineView.expandItem(item)
    }

    /// Get the appropriate color for the items icon depending on the users preferences.
    /// - Parameter item: The `FileItem` to get the color for
    /// - Returns: A `NSColor` for the given `FileItem`.
    private func color(for item: WorkspaceClient.FileItem) -> NSColor {
        if item.children == nil && iconColor == .color {
            return NSColor(item.iconColor)
        } else {
            return .secondaryLabelColor
        }
    }
}

// MARK: - NSOutlineViewDataSource

extension OutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? WorkspaceClient.FileItem {
            return item.children?.count ?? 0
        }
        return content.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? WorkspaceClient.FileItem,
           let children = item.children {
            return children[index]
        }
        return content[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? WorkspaceClient.FileItem {
            return item.children != nil
        }
        return false
    }
}

// MARK: - NSOutlineViewDelegate

extension OutlineViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowCellExpansionFor tableColumn: NSTableColumn?, item: Any) -> Bool {
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        guard let tableColumn = tableColumn else { return nil }

        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: 17)

        let view = OutlineTableViewCell(frame: frameRect)

        if let item = item as? WorkspaceClient.FileItem {
            let image = NSImage(systemSymbolName: item.systemImage, accessibilityDescription: nil)!
            view.icon.image = image
            view.icon.contentTintColor = color(for: item)

            view.label.stringValue = item.fileName
        }

        return view
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }

        let selectedIndex = outlineView.selectedRow

        guard let item = outlineView.item(atRow: selectedIndex) as? WorkspaceClient.FileItem else { return }

        if item.children == nil {
            workspace?.openFile(item: item)
        }
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 22 // This can be changed to 20 to match Xcodes row height.
    }

    func outlineViewItemDidExpand(_ notification: Notification) {
        updateSelection()
    }
}

extension OutlineViewController: NSMenuDelegate {

    /// Once a menu gets requested by a `right click` setup the menu
    ///
    /// If the right click happened outside a row this will result in no menu being shown.
    /// - Parameter menu: The menu that got requested
    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = outlineView.clickedRow
        guard let menu = menu as? OutlineMenu else { return }

        if row == -1 {
            menu.item = nil
        } else {
            if let item = outlineView.item(atRow: row) as? WorkspaceClient.FileItem {
                menu.item = item
            } else {
                menu.item = nil
            }
        }
        menu.update()
    }
}
