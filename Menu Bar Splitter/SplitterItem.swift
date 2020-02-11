//
//  SplitterItem.swift
//  Menu Bar Splitter 3
//
//  Created by Justin Hamilton on 11/26/19.
//  Copyright © 2019 Justin Hamilton. All rights reserved.
//

import Cocoa
import ObjectiveC

class SplitterItem: NSStatusItem, NSMenuDelegate {
    
    var statusItem: NSStatusItem!
    var statusIndex: Int!
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var cacheBCVRunning = false
    
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
    
    func refreshMenu() {
        statusItem.menu = makeMainMenu()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        self.cacheBCVRunning = appDelegate.checkIfBCVRunning()
        UserDefaults.standard.set(appDelegate.checkIfBCVRunning(), forKey: "bcvEnabled")
        if(self.cacheBCVRunning) {
            self.statusItem.menu?.item(at: 5)?.state = .on
        } else {
            self.statusItem.menu?.item(at: 5)?.state = .off
        }
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
        
        let bcvItem = NSMenuItem(title: "Bartender Compatibility", action: #selector(self.toggleBCV), keyEquivalent: "")
        if(UserDefaults.standard.bool(forKey: "bcvEnabled")) {
            bcvItem.state = .on
        }
        
        let aboutItem = NSMenuItem(title: "About", action: #selector(AppDelegate.showAbout), keyEquivalent: "")
        let quitItem = NSMenuItem(title: "Quit", action: #selector(AppDelegate.quitSelected), keyEquivalent: "")
        
        removeItem.target = self
        openAtLoginItem.target = self
        bcvItem.target = self
        
        mainMenu.addItem(addItem); mainMenu.addItem(removeItem); mainMenu.addItem(iconItem)
        mainMenu.addItem(NSMenuItem.separator())
        mainMenu.addItem(openAtLoginItem);mainMenu.addItem(bcvItem)
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
    
    @objc func openAtLogin() {
        appDelegate.openAtLogin()
    }
    
    @objc func toggleBCV() {
        appDelegate.toggleBCV()
    }
    
    init(index: Int) {
        super.init()
        
        statusIndex = index
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(named: "lineIcon")
        statusItem.autosaveName = ("mbsItem\(index)")
        statusItem.button?.image?.isTemplate = true
        statusItem.isVisible = true
        
        self.cacheBCVRunning = appDelegate.checkIfBCVRunning()
        
        statusItem.menu = makeMainMenu()
    }
}
