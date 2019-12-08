//
//  SplitterItem.swift
//  Menu Bar Splitter 3
//
//  Created by Justin Hamilton on 11/26/19.
//  Copyright © 2019 Justin Hamilton. All rights reserved.
//

import Cocoa
import ObjectiveC

class SplitterItem: NSStatusItem {
    
    var statusItem: NSStatusItem!
    var statusIndex: Int!
    
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
        
        lineItem.target = self
        dotItem.target = self
        
        iconMenu.addItem(blankItem); iconMenu.addItem(lineItem); iconMenu.addItem(dotItem)
        
        return iconMenu
    }
    
    func makeMainMenu()->NSMenu {
        let mainMenu = NSMenu()
        
        let addItem = NSMenuItem(title: "Add Splitter", action: #selector(AppDelegate.addItem), keyEquivalent: "")
        let removeItem = NSMenuItem(title: "Remove Splitter", action: #selector(AppDelegate.removeItem(sender:)), keyEquivalent: "")
        let iconItem = NSMenuItem(title: "Set Icon...", action: nil, keyEquivalent: "")
        iconItem.submenu = makeIconMenu()
        
        let openAtLoginItem = NSMenuItem(title: "Open At Login", action: #selector(self.openAtLogin), keyEquivalent: "")
        let aboutItem = NSMenuItem(title: "About", action: #selector(AppDelegate.showAbout), keyEquivalent: "")
        let quitItem = NSMenuItem(title: "Quit", action: #selector(AppDelegate.quitSelected), keyEquivalent: "")
        
        openAtLoginItem.target = self
        
        mainMenu.addItem(addItem); mainMenu.addItem(removeItem); mainMenu.addItem(iconItem)
        mainMenu.addItem(NSMenuItem.separator())
        mainMenu.addItem(openAtLoginItem);mainMenu.addItem(aboutItem); mainMenu.addItem(quitItem)
        
        return mainMenu
    }
    
    @objc func setBlankIcon() {
        statusItem.button?.image = NSImage(named: "blankIcon")
    }
    
    @objc func setLineIcon() {
        statusItem.button?.image = NSImage(named: "lineIcon")
    }
    
    @objc func setThinBlankIcon() {
        statusItem.button?.image = NSImage(named: "thinBlankIcon")
    }
    
    @objc func setDotIcon() {
        statusItem.button?.image = NSImage(named: "dotIcon")
    }
    
    @objc func openAtLogin() {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.icon = NSImage(named: "AppIcon")
        alert.informativeText = "To open at login, go to:\n\nSystem Preferences > Users & Groups > Your Name > Login Items\n\nPress + and add Menu Bar Splitter (Bartender Compatibility Version)."
        alert.messageText = "Open At Login"
        alert.runModal()
    }
    
    init(index: Int) {
        super.init()
        
        statusIndex = index
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(named: "lineIcon")
        statusItem.autosaveName = ("mbsItem\(index)")
        statusItem.button?.image?.isTemplate = true
        statusItem.isVisible = true
        
        statusItem.menu = makeMainMenu()
    }
}
