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

    @IBOutlet weak var window: NSWindow!
    var itemArray: [SplitterItem] = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
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
    
    @objc func showAbout() {
        window.makeKeyAndOrderFront(NSWorkspace.shared)
    }
    
    @objc func addItem() {
        itemArray.append(SplitterItem(index: itemArray.count))
    }
    
    @objc func removeItem(sender: Any) {
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
            if(getIndex(sender: sender) == itemArray.count-1) {
                itemArray.removeLast()
            } else {
                (getIndex(sender: sender)+1...itemArray.count-1).forEach({(i) in
                    itemArray[i].statusIndex-=1
                })
                itemArray.remove(at: getIndex(sender: sender))
            }
        }
    }
    
    @objc func quitSelected() {
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
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func openWebsite(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://www.jwhamilton.co")!)
    }
}

