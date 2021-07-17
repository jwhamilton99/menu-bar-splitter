//
//  AppDelegate.swift
//  Menu Bar Splitter
//
//  Created by Justin Hamilton on 12/2/19.
//  Copyright © 2019 Justin Hamilton. All rights reserved.
//

import Cocoa
import ServiceManagement
import SwiftUI

class ManageWindow: NSWindow {
    var appDelegate: AppDelegate!
    
    override func close() {
        self.appDelegate.refreshAllItems()
        self.orderOut(NSApp)
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var itemArray: [SplitterItem] = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if(UserDefaults.standard.object(forKey: "numItems") == nil) {
            UserDefaults.standard.set(0, forKey: "numItems")
        }
        
        if(UserDefaults.standard.integer(forKey:"numItems") == 0) {
            self.addItem()
        } else {
            if let itemsStr = UserDefaults.standard.object(forKey: "itemsStr") as? String {
                let itemsArr = itemsStr.split(separator: ";")
                for item in itemsArr {
                    let splStr = item.split(separator: ",")
                    if(splStr.count == 4) {
                        let newSplitter = SplitterItem(index: self.itemArray.count, id: String(splStr[0]))
                        newSplitter.updatePrefs = false
                        newSplitter.id = String(splStr[0])
                        if(Int(splStr[1]) != -1) {
                            switch(Int(splStr[1])) {
                            case 0:
                                newSplitter.setBlankIcon()
                                break
                            case 2:
                                newSplitter.setDotIcon()
                                break
                            case 3:
                                newSplitter.setThinBlankIcon()
                                break
                            default:
                                newSplitter.setLineIcon()
                                break
                            }
                        } else {
                            newSplitter.forceSetCustomImage(id: String(splStr[2]))
                            if(Int(splStr[3]) == 1) {
                                newSplitter.setTemplate(true)
                            } else {
                                newSplitter.setTemplate(false)
                            }
                        }
                        newSplitter.updatePrefs = true
                        self.itemArray.append(newSplitter)
                    } else {
                        let newSplitter = SplitterItem(index: self.itemArray.count)
                        self.itemArray.append(newSplitter)
                    }
                }
                self.savePrefs()
            } else {
                if let iconStr = UserDefaults.standard.object(forKey:"iconStr") as? String {
                    let iconStrArr = Array(iconStr)
                    for i in 0...UserDefaults.standard.integer(forKey:"numItems")-1 {
                        self.addItem(false)
                        switch(iconStrArr[i]) {
                        case "0":
                            itemArray.last?.setBlankIcon()
                            break
                        case "1":
                            itemArray.last?.setLineIcon()
                            break
                        case "2":
                            itemArray.last?.setDotIcon()
                            break
                        case "3":
                            itemArray.last?.setThinBlankIcon()
                            break
                        default:
                            break
                        }
                    }
                    UserDefaults.standard.set(nil, forKey: "iconStr")
                    self.savePrefs()
                }
            }
        }
        
        refreshAllItems()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        self.savePrefs()
    }

    @objc func getIndex(sender: Any)->Int {
        var idx = -1
        let menu = (sender as! NSMenuItem).menu
        itemArray.forEach({(i) in
            if(i.statusItem.menu == menu) {
                idx = i.statusIndex
            }
        })
        return idx
    }
    
    @objc func showAbout() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(NSWorkspace.shared)
    }
    
    @objc func showManage() {
        let w = ManageWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 500), styleMask: [.closable, .titled], backing: .buffered, defer: false)
        guard let viewController = NSStoryboard(name: "ManageCustom", bundle: .main).instantiateInitialController() as? ManageCustomViewController else { return }
        viewController.appDelegate = self
        w.contentViewController = viewController
        viewController.window = w
        
        w.appDelegate = self
        w.title = "Manage Icons"
        NSApplication.shared.activate(ignoringOtherApps: true)
        w.makeKeyAndOrderFront(NSWorkspace.shared)
    }
    
    @objc func addItem(_ updatePrefs: Bool = true) {
        itemArray.append(SplitterItem(index: itemArray.count))
        if(updatePrefs) {
            self.savePrefs()
        }
    }
    
    @objc func removeItem(index: Int) {
        if(itemArray.count == 1) {
            itemArray.removeFirst()
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.icon = NSImage(named: "AppIcon")
            alert.messageText = "No More Splitters"
            alert.informativeText = "You've removed the last splitter. Would you like to add a new splitter or close the application?"
            alert.addButton(withTitle: "Add Splitter")
            alert.addButton(withTitle: "Quit")
            let res = alert.runModal()
            switch(res.rawValue) {
            case 1000:
                //add new
                self.addItem()
                break
            case 1001:
                //quit
                self.quitSelected()
                break
            default:
                break
            }
        } else {
            if(index == itemArray.count-1) {
                itemArray.removeLast()
            } else if(index == 0) {
                itemArray.removeFirst()
            } else {
                itemArray.remove(at: index)
            }
        }
        
        var newIndex = 0
        itemArray.forEach({(i) in
            i.statusIndex = newIndex
            newIndex+=1
        })
        self.savePrefs()
    }
    
    func savePrefs() {
        UserDefaults.standard.set(itemArray.count, forKey: "numItems")
        
        var itemsStr = ""
        
        for item in self.itemArray {
            var itemStr = item.id
            itemStr.append(",\(item.builtinIconKey)")
            itemStr.append(",\((item.builtinIconKey == -1) ? item.customIconID : "-1")")
            itemStr.append(",\((item.builtinIconKey == -1) ? ((item.isTemplate) ? "1" : "0") : "0")")
            itemsStr.append(itemStr)
            itemsStr.append(";")
        }
        
        UserDefaults.standard.set(itemsStr, forKey: "itemsStr")
        refreshAllItems()
    }
    
    @objc func quitSelected() {
        self.savePrefs()
        NSApplication.shared.terminate(self)
    }
    
    @objc func openAtLogin() {
        if(UserDefaults.standard.bool(forKey: "launchAtLogin")) {
            UserDefaults.standard.set(false, forKey: "launchAtLogin")
            if(!SMLoginItemSetEnabled("justinhamilton.Menu-Bar-Splitter-AutoLaunch" as CFString, false)) {
                print("Could not set login item")
            }
        } else {
            UserDefaults.standard.set(true, forKey: "launchAtLogin")
            if(!SMLoginItemSetEnabled("justinhamilton.Menu-Bar-Splitter-AutoLaunch" as CFString, true)) {
                print("Could not set login item")
            }
        }
        
        itemArray.forEach({(i) in
            i.refreshMenu()
        })
    }
    
    func refreshAllItems() {
        itemArray.forEach({(i) in
            i.refreshItem()
        })
    }
    
    func addCustomImage() -> String? {
        if let uuid = selectCustomItem() {
            return uuid
        }
        return nil
    }
    
    @IBAction func openWebsite(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://www.jwhamilton.co")!)
    }
    
    @IBAction func openSource(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/jwhamilton99/menu-bar-splitter")!)
    }
}

