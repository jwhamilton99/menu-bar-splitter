//
//  AppDelegate.swift
//  Menu Bar Splitter
//
//  Created by Justin Hamilton on 12/2/19.
//  Copyright © 2019 Justin Hamilton. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var itemArray: [SplitterItem] = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if(UserDefaults.standard.integer(forKey:"numItems") == 0) {
            self.addItem()
        } else {
            let iconStr = UserDefaults.standard.string(forKey:"iconStr")!
            let iconStrArr = Array(iconStr)
            for i in 0...UserDefaults.standard.integer(forKey:"numItems")-1 {
                self.addItem()
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
        }
        
        refreshAllItems()
        
        if(UserDefaults.standard.bool(forKey: "bcvEnabled")) {
            launchBCV()
        }
    }
    
    func checkIfBCVRunning() -> Bool {
        let bcvRunning = !(NSWorkspace.shared.runningApplications).filter { $0.bundleIdentifier == "justinhamilton.Menu-Bar-Splitter-BCV"}.isEmpty
        
        return bcvRunning
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        if(UserDefaults.standard.bool(forKey: "bcvEnabled")) {
            if(checkIfBCVRunning()) {
                self.closeBCV()
            }
        }
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
        window.makeKeyAndOrderFront(NSWorkspace.shared)
    }
    
    @objc func addItem() {
        itemArray.append(SplitterItem(index: itemArray.count))
        self.savePrefs()
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
    }
    
    func savePrefs() {
        UserDefaults.standard.set(itemArray.count, forKey: "numItems")
        var icoStr = ""
        itemArray.forEach({(i) in
            var iconInd = 0
            switch(i.statusItem.button?.image?.name()!) {
            case "blankIcon":
                iconInd = 0
                break
            case "lineIcon":
                iconInd = 1
                break
            case "dotIcon":
                iconInd = 2
                break
            case "thinBlankIcon":
                iconInd = 3
                break
            default:
                break
            }
            icoStr = "\(icoStr)\(iconInd)"
        })
        UserDefaults.standard.set(icoStr, forKey: "iconStr")
        refreshAllItems()
    }
    
    @objc func quitSelected() {
        self.savePrefs()
        if(UserDefaults.standard.bool(forKey: "bcvEnabled")) {
            self.closeBCV()
        }
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
            i.refreshMenu()
        })
    }
    
    func closeBCV() {
        DistributedNotificationCenter.default().post(name: NSNotification.Name("justinhamilton.Menu-Bar-Splitter.quitBCVNotification"), object: nil)
    }
    
    func launchBCV() {
        let bcvURL = (Bundle.main.bundleURL.appendingPathComponent("Contents", isDirectory: true).appendingPathComponent("Library", isDirectory: true).appendingPathComponent("BCV", isDirectory: true).appendingPathComponent("Menu Bar Splitter (Bartender Compatibility Version).app", isDirectory: false))
        do {
            try NSWorkspace.shared.launchApplication(at: bcvURL, options: .default, configuration: [:])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func toggleBCV() {
        if(UserDefaults.standard.bool(forKey: "bcvEnabled")) {
            UserDefaults.standard.set(false, forKey: "bcvEnabled")
            closeBCV()
        } else {
            UserDefaults.standard.set(true, forKey: "bcvEnabled")
            launchBCV()
            let bcvAlert = NSAlert()
            bcvAlert.messageText = "Bartender Compatibility Mode"
            bcvAlert.informativeText = "You've just enabled Bartender Compatibility Mode.\n\nThis lets you use Menu Bar Splitter with Bartender, an amazing menu bar organization app.\n\nWould you like to learn how to use Bartender Compatibility Mode?"
            bcvAlert.showsSuppressionButton = true
            bcvAlert.addButton(withTitle: "Yes")
            bcvAlert.addButton(withTitle: "No")
            let res = bcvAlert.runModal()
            switch(res.rawValue) {
            case 1000:
                print("yes")
                break
            case 1001:
                //quit
                print("no")
                break
            default:
                break
            }
        }
        
        refreshAllItems()
    }
    
    @IBAction func openWebsite(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://www.jwhamilton.co")!)
    }
}

