//
//  ManageCustomCollectionItem.swift
//  Menu Bar Splitter
//
//  Created by Justin Hamilton on 3/19/21.
//  Copyright © 2021 Justin Hamilton. All rights reserved.
//

import Cocoa

class ManageCustomCollectionItem: NSCollectionViewItem {
    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var buttonStack: NSStackView!
    
    var parentVC: ManageCustomViewController!
    var icon: CustomIcon? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.cornerRadius = 10
    }
    
    @IBAction func rename(_ sender: Any) {
        if let icon = self.icon {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            alert.messageText = "Rename Icon"
            
            let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            alert.accessoryView = textField
            
            alert.beginSheetModal(for: self.parentVC.window, completionHandler: {(response) in
                if(response == .alertFirstButtonReturn) {
                    renameItem(id: icon.id, textField.stringValue)
                    self.parentVC.appDelegate.refreshAllItems()
                    self.parentVC.refreshIcons()
                    self.parentVC.collectionView.reloadData()
                }
            })
        }
    }
    
    @IBAction func delete(_ sender: Any) {
        if let icon = self.icon {
            deleteItem(id: icon.id)
            self.parentVC.appDelegate.refreshAllItems()
            self.parentVC.refreshIcons()
            self.parentVC.collectionView.reloadData()
        }
    }
}
