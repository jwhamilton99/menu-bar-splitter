//
//  AppDelegate.swift
//  Menu Bar Splitter
//
//  Created by Justin Hamilton on 12/2/19.
//  Copyright © 2019 Justin Hamilton. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var itemArray: [SplitterItem] = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if(UserDefaults.standard.integer(forKey:"numItemsBCV") == 0) {
            self.addItem()
        } else {
            let iconStr = UserDefaults.standard.string(forKey:"iconStrBCV")!
            let iconStrArr = Array(iconStr)
            for i in 0...UserDefaults.standard.integer(forKey:"numItemsBCV")-1 {
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
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.receivedQuitRequest(notification:)), name: NSNotification.Name(rawValue: "justinhamilton.Menu-Bar-Splitter.quitBCVNotification"), object: nil)
        refreshAllItems()
    }
    
    @objc func receivedQuitRequest(notification: Notification) {
        self.quitSelected()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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
    
    func refreshAllItems() {
        itemArray.forEach({(i) in
            i.refreshMenu()
        })
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
            alert.messageText = "No More Dividers"
            alert.informativeText = "You've removed the last divider. Would you like to add a new divider or close the application?"
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
        UserDefaults.standard.set(itemArray.count, forKey: "numItemsBCV")
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
        
        UserDefaults.standard.set(icoStr, forKey: "iconStrBCV")
        refreshAllItems()
    }
    
    @objc func quitSelected() {
        self.savePrefs()
        NSApplication.shared.terminate(self)
    }
}

