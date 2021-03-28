//
//  ManageCustomViewController.swift
//  Menu Bar Splitter
//
//  Created by Justin Hamilton on 3/19/21.
//  Copyright © 2021 Justin Hamilton. All rights reserved.
//

import Cocoa
import CoreGraphics

class ManageCustomViewController: NSViewController {

    var appDelegate: AppDelegate!
    
    var icons: [CustomIcon] = []
    
    var window: NSWindow!
    
    @IBOutlet weak var collectionView: NSCollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.refreshIcons()
        self.configureCollectionView()
    }
    
    func refreshIcons() {
        self.icons = []
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: sharedGroupIdentifier) {
            let supportURL = containerURL.appendingPathComponent("Library/Application Support/Menu-Bar-Splitter", isDirectory: true)
            let customIconsURL = (supportURL.appendingPathComponent("customIcons", isDirectory: true))
            let customIconsDataURL = customIconsURL.appendingPathComponent("data.json", isDirectory: false)
            
            do {
                if let data = FileManager.default.contents(atPath: customIconsDataURL.path), let object = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    for item in object {
                        if let v = item.value as? [String: Any], let nickname = v["nickname"] as? String, let urlStr = v["url"] as? String {
                            let url = NSURL.fileURL(withPath: urlStr)
                            if let imageData = FileManager.default.contents(atPath: urlStr), let image = NSImage(data: imageData) {
                                self.icons.append(CustomIcon(nickname: nickname, url: url, image: image, id: item.key))
                            }
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        self.icons.sort(by: {$0.nickname < $1.nickname})
    }
    
    @IBAction func addIcon(_ sender: Any) {
        if let _ = self.appDelegate.addCustomImage() {
            self.refreshIcons()
            self.collectionView.reloadData()
        }
    }
}

extension NSImage {
    var smallBitmap: NSBitmapImageRep? {
        guard let data = self.tiffRepresentation, let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        
        guard let resized = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, [
            kCGImageSourceThumbnailMaxPixelSize: 16 as NSObject,
            kCGImageSourceCreateThumbnailFromImageAlways: true as NSObject
        ] as CFDictionary) else { return nil }
        
        let bitmap = NSBitmapImageRep(cgImage: resized)
        return bitmap
        
    }
    
    var hasAlphaChannel: Bool {
        guard let b = self.smallBitmap else { return false }
        
        for i in 0..<Int(b.size.width) {
            for j in 0..<Int(b.size.height) {
                if(b.colorAt(x: i, y: j)?.alphaComponent != 1.0) {
                    return true
                }
            }
        }
        
        return false
    }
    
    var colorDataEqual: Bool {
        guard let b = self.smallBitmap else { return false }
        
        for i in 0..<Int(b.size.height) {
            for j in 1..<Int(b.size.width) {
                if let b1 = b.colorAt(x: j, y: i), let b2 = b.colorAt(x: j-1, y: i) {
                    if(b1.greenComponent != 0 && b1.blueComponent != 0 && b2.greenComponent != 0 && b2.blueComponent != 0) {
                        let r1 = ((b1.redComponent/b1.greenComponent)+(b1.greenComponent/b1.blueComponent))/2
                        let r2 = ((b2.redComponent/b2.greenComponent)+(b2.greenComponent/b2.blueComponent))/2
                        if(r1 != r2) {
                            return false
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    var smallImage: NSImage? {
        guard let b = self.smallBitmap, let image = b.cgImage else { return nil }
        return NSImage(cgImage: image, size: CGSize(width: image.width, height: image.height))
    }
    
    var brightness: CGFloat? {
        guard let data = self.tiffRepresentation, let input = CIImage(data: data) else { return nil }
        let extent = CIVector(x: input.extent.origin.x, y: input.extent.origin.y, z: input.extent.size.width, w: input.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: input, kCIInputExtentKey: extent]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var b = [UInt8](repeating: 0, count: 4)
        let c = CIContext(options: [.workingColorSpace: kCFNull as Any])
        c.render(outputImage, toBitmap: &b, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        return (CGFloat(b[0])+CGFloat(b[1])+CGFloat(b[2]))/765
    }
}

extension ManageCustomViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.icons.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let item = self.collectionView.makeItem(withIdentifier: .init("customIconCollectionViewItem"), for: indexPath) as? ManageCustomCollectionItem else {return NSCollectionViewItem()}
        item.parentVC = self
        item.iconImageView.image = self.icons[indexPath.item].image
        if(item.iconImageView.image!.hasAlphaChannel && item.iconImageView.image!.colorDataEqual) {
            item.iconImageView.image!.isTemplate = true
            item.iconImageView.contentTintColor = NSColor.labelColor
        } else {
            item.iconImageView.image!.isTemplate = false
            item.iconImageView.contentTintColor = NSColor.clear
        }
        
        item.iconImageView.contentTintColor = .none
        
        item.titleLabel.stringValue = self.icons[indexPath.item].nickname
        item.titleLabel.textColor = .labelColor
        item.buttonStack.isHidden = false
        
        item.icon = self.icons[indexPath.item]
        return item
    }
    
    
    
    func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.isSelectable = true
        self.collectionView.allowsEmptySelection = true
        
        self.collectionView.enclosingScrollView?.borderType = .bezelBorder
        
        let n = NSNib(nibNamed: "ManageCustomCollectionItem", bundle: nil)
        self.collectionView.register(n, forItemWithIdentifier: .init("customIconCollectionViewItem"))
        
        self.configureFlowLayout()
    }
    
    func configureFlowLayout() {
        let layout = NSCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 30.0
        layout.minimumLineSpacing = 30.0
        layout.sectionInset = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = NSSize(width: 100, height: 150)
        self.collectionView.collectionViewLayout = layout
    }
}
