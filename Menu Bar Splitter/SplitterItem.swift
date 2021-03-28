//
//  SplitterItem.swift
//  Menu Bar Splitter 3
//
//  Created by Justin Hamilton on 11/26/19.
//  Copyright © 2019 Justin Hamilton. All rights reserved.
//

import Cocoa
import ObjectiveC

class IconMenuItem: NSMenuItem {
    var imageID: String
    init(title: String, action: Selector?, keyEquivalent: String, imageID: String) {
        self.imageID = imageID
        super.init(title: title, action: action, keyEquivalent: keyEquivalent)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SplitterItem: NSStatusItem, NSMenuDelegate {
    
    var id: String = ""
    var statusItem: NSStatusItem!
    var statusIndex: Int!
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var builtinIconKey = 1
    var customIconID = ""
    var isTemplate = false
    
    @objc func addCustomFromItem() {
        if let uuid = self.appDelegate.addCustomImage(), let image = getCustomItem(for: uuid) {
            self.builtinIconKey = -1
            self.customIconID = uuid
            var height: CGFloat = 20
            if let mb = NSApplication.shared.mainMenu {
                height = mb.menuBarHeight
            }
            
            image.size.width = (height/image.size.height)*image.size.width
            image.size.height = height
            
            if(image.hasAlphaChannel && image.colorDataEqual) {
                image.isTemplate = true
            } else {
                image.isTemplate = false
            }
            self.isTemplate = image.isTemplate
            
            statusItem.button?.image = image
            self.appDelegate.refreshAllItems()
            
            appDelegate.savePrefs()
        }
    }
    
    @objc func setCustomMenuItem(sender: IconMenuItem) {
        if let image = getCustomItem(for: sender.imageID) {
            self.customIconID = sender.imageID
            self.builtinIconKey = -1
            
            if(image.hasAlphaChannel && image.colorDataEqual) {
                image.isTemplate = true
            } else {
                image.isTemplate = false
            }
            self.isTemplate = image.isTemplate
            
            guard let button = statusItem.button else { return }
            button.image = image
            self.refreshItem()
            
            self.appDelegate.savePrefs()
        }
    }
    
    @objc func toggleTemplate() {
        guard let button = statusItem.button, let image = button.image else { return }
        image.isTemplate = !image.isTemplate
        self.isTemplate = image.isTemplate
        self.refreshItem()
        self.appDelegate.savePrefs()
    }
    
    func setTemplate(_ isTemplate: Bool) {
        guard let button = statusItem.button, let image = button.image else { return }
        image.isTemplate = isTemplate
        self.isTemplate = image.isTemplate
        self.refreshItem()
        self.appDelegate.savePrefs()
    }
    
    func forceSetCustomImage(id: String) {
        var height: CGFloat = 20
        
        if let mb = NSApplication.shared.mainMenu {
            height = mb.menuBarHeight
        }
        
        guard let image = getCustomItem(for: id) else { self.setLineIcon(); return }
        
        image.size.width = (height/image.size.height)*image.size.width
        image.size.height = height
        
        guard let button = statusItem.button else { return }
        button.image = image
        self.customIconID = id
        self.builtinIconKey = -1
    }
    
    func makeCustomMenu()->NSMenu {
        let menu = NSMenu()
        
        let noCustomItem = NSMenuItem(title: "No Custom Icons Found", action: nil, keyEquivalent: "")
        var customIconMenuItems: [NSMenuItem] = []
        
        if let customItems = getCustomItems() {
            var i = 1
            for item in customItems {
                let newItem = IconMenuItem(title: getNickname(for: item.key) ?? "Icon \(i)", action: #selector(self.setCustomMenuItem(sender:)), keyEquivalent: "", imageID: item.key)
                
                let image = item.value
                if(image.hasAlphaChannel && image.colorDataEqual) {
                    image.isTemplate = true
                } else {
                    image.isTemplate = false
                }
                
                newItem.image = image
                newItem.target = self
                customIconMenuItems.append(newItem)
                i+=1
            }
        }
        
        let addCustomItem = NSMenuItem(title: "Add Custom Icon", action: #selector(self.addCustomFromItem), keyEquivalent: "")
        addCustomItem.target = self
        
        let manageCustomItem = NSMenuItem(title: "Manage Icons...", action: #selector(self.appDelegate.showManage), keyEquivalent:  "")
        manageCustomItem.target = self.appDelegate
        
        if(customIconMenuItems.count == 0) {
            menu.addItem(noCustomItem)
        } else {
            for item in customIconMenuItems {
                menu.addItem(item)
            }
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(addCustomItem)
        menu.addItem(manageCustomItem)
        
        return menu
    }
    
    func makeIconMenu()->NSMenu {
        let iconMenu = NSMenu()
    
        let blankMenu = NSMenu()
        let thickBlankItem = NSMenuItem(title: "Thick", action: #selector(self.setBlankIcon), keyEquivalent: "")
        let thinBlankItem = NSMenuItem(title: "Thin", action: #selector(self.setThinBlankIcon), keyEquivalent: "")
        thickBlankItem.target = self
        thinBlankItem.target = self
        blankMenu.addItem(thickBlankItem); blankMenu.addItem(thinBlankItem)
        
        let blankItem = NSMenuItem(title: "Blank...", action: nil, keyEquivalent: "")
        blankItem.submenu = blankMenu
        
        let lineItem = NSMenuItem(title: "Line", action: #selector(self.setLineIcon), keyEquivalent: "")
        let dotItem = NSMenuItem(title: "Dot", action: #selector(self.setDotIcon), keyEquivalent: "")
        
        let customItem = NSMenuItem(title: "Custom...", action: nil, keyEquivalent: "")
        customItem.submenu = makeCustomMenu()
        
        lineItem.target = self
        dotItem.target = self
        
        if(self.builtinIconKey != -1) {
            switch(builtinIconKey) {
            case 0:
                thickBlankItem.state = .on
                break
            case 1:
                lineItem.state = .on
                break
            case 2:
                dotItem.state = .on
                break
            case 3:
                thinBlankItem.state = .on
                break
            default:
                break
            }
        }
        
        iconMenu.addItem(blankItem); iconMenu.addItem(lineItem); iconMenu.addItem(dotItem); iconMenu.addItem(NSMenuItem.separator()); iconMenu.addItem(customItem)
        
        return iconMenu
    }
    
    func refreshItem() {
        if(self.customIconID != "") {
            if(getCustomItem(for: self.customIconID) == nil) {
                self.setLineIcon()
            }
        }
        self.refreshMenu()
    }
    
    func refreshMenu() {
        statusItem.menu = makeMainMenu()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        appDelegate.refreshAllItems()
    }
    
    func makeMainMenu()->NSMenu {
        let mainMenu = NSMenu()
        
        let addItem = NSMenuItem(title: "Add Splitter", action: #selector(AppDelegate.addItem), keyEquivalent: "")
        let removeItem = NSMenuItem(title: "Remove Splitter", action: #selector(self.removeItem), keyEquivalent: "")
        let iconItem = NSMenuItem(title: "Set Icon...", action: nil, keyEquivalent: "")
        iconItem.submenu = makeIconMenu()
        
        let openAtLoginItem = NSMenuItem(title: "Open At Login", action: #selector(self.openAtLogin), keyEquivalent: "")
        if(UserDefaults.standard.bool(forKey: "launchAtLogin")) {
            openAtLoginItem.state = .on
        }
        
        let aboutItem = NSMenuItem(title: "About", action: #selector(AppDelegate.showAbout), keyEquivalent: "")
        let quitItem = NSMenuItem(title: "Quit", action: #selector(AppDelegate.quitSelected), keyEquivalent: "")
        
        removeItem.target = self
        openAtLoginItem.target = self
        
        if(self.customIconID != "") {
            let templateItem = NSMenuItem(title: "Follow System Appearance", action: #selector(self.toggleTemplate), keyEquivalent: "")
            if(self.isTemplate) {
                templateItem.state = .on
            } else {
                templateItem.state = .off
            }
            templateItem.target = self
            mainMenu.addItem(templateItem)
            mainMenu.addItem(NSMenuItem.separator())
        }
        
        mainMenu.addItem(addItem); mainMenu.addItem(removeItem); mainMenu.addItem(iconItem)
        mainMenu.addItem(NSMenuItem.separator())
        mainMenu.addItem(openAtLoginItem)
        mainMenu.addItem(NSMenuItem.separator())
        mainMenu.addItem(aboutItem); mainMenu.addItem(quitItem)
        
        mainMenu.delegate = self
        
        return mainMenu
    }
    
    @objc func removeItem() {
        appDelegate.removeItem(index: self.statusIndex)
    }
    
    @objc func setBlankIcon() {
        statusItem.button?.image = NSImage(named: "blankIcon")
        self.customIconID = ""
        self.builtinIconKey = 0
        self.appDelegate.savePrefs()
        self.appDelegate.refreshAllItems()
    }
    
    @objc func setLineIcon() {
        statusItem.button?.image = NSImage(named: "lineIcon")
        self.customIconID = ""
        self.builtinIconKey = 1
        appDelegate.savePrefs()
        self.appDelegate.refreshAllItems()
    }
    
    @objc func setThinBlankIcon() {
        statusItem.button?.image = NSImage(named: "thinBlankIcon")
        self.customIconID = ""
        self.builtinIconKey = 3
        appDelegate.savePrefs()
        self.appDelegate.refreshAllItems()
    }
    
    @objc func setDotIcon() {
        statusItem.button?.image = NSImage(named: "dotIcon")
        self.customIconID = ""
        self.builtinIconKey = 2
        appDelegate.savePrefs()
        self.appDelegate.refreshAllItems()
    }
    
    @objc func openAtLogin() {
        appDelegate.openAtLogin()
    }
    
    init(index: Int, id: String) {
        super.init()
        
        self.id = id
        
        statusIndex = index
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(named: "lineIcon")
        statusItem.autosaveName = id
        statusItem.button?.image?.isTemplate = true
        statusItem.isVisible = true
        
        statusItem.menu = makeMainMenu()
    }
    
    init(index: Int) {
        super.init()
        self.id = UUID().uuidString
        
        statusIndex = index
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(named: "lineIcon")
        statusItem.autosaveName = (self.id)
        statusItem.button?.image?.isTemplate = true
        statusItem.isVisible = true
        
        statusItem.menu = makeMainMenu()
    }
}
