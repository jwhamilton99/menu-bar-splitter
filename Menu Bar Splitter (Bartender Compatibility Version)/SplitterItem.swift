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
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    
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
        switch(statusItem.button?.image?.name()) {
        case "lineIcon":
            lineItem.state = .on
            break
        case "dotIcon":
            dotItem.state = .on
            break
        case "blankIcon":
            thickBlankItem.state = .on
            break
        case "thinBlankIcon":
            thinBlankItem.state = .on
            break
        default:
            break
        }
        
        iconMenu.addItem(blankItem); iconMenu.addItem(lineItem); iconMenu.addItem(dotItem)
        
        return iconMenu
    }
    
    func makeMainMenu()->NSMenu {
        let mainMenu = NSMenu()
        
        let addItem = NSMenuItem(title: "Add Splitter", action: #selector(AppDelegate.addItem), keyEquivalent: "")
        let removeItem = NSMenuItem(title: "Remove Splitter", action: #selector(self.removeItem), keyEquivalent: "")
        let iconItem = NSMenuItem(title: "Set Icon...", action: nil, keyEquivalent: "")
        iconItem.submenu = makeIconMenu()
        let quitItem = NSMenuItem(title: "Quit BCV", action: #selector(self.quitSelected), keyEquivalent: "")
        
        removeItem.target = self
        
        mainMenu.addItem(addItem); mainMenu.addItem(removeItem); mainMenu.addItem(iconItem)
        mainMenu.addItem(NSMenuItem.separator())
        mainMenu.addItem(quitItem)
        
        return mainMenu
    }
    
    @objc func removeItem() {
        appDelegate.removeItem(index: self.statusIndex)
    }
    
    @objc func quitSelected() {
        appDelegate.quitSelected()
    }
    
    @objc func setBlankIcon() {
        statusItem.button?.image = NSImage(named: "blankIcon")
        appDelegate.savePrefs()
    }
    
    @objc func setLineIcon() {
        statusItem.button?.image = NSImage(named: "lineIcon")
        appDelegate.savePrefs()
    }
    
    @objc func setThinBlankIcon() {
        statusItem.button?.image = NSImage(named: "thinBlankIcon")
        appDelegate.savePrefs()
    }
    
    @objc func setDotIcon() {
        statusItem.button?.image = NSImage(named: "dotIcon")
        appDelegate.savePrefs()
    }
    
    func refreshMenu() {
        statusItem.menu = makeMainMenu()
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
