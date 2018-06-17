//
//  AppDelegate.swift
//  DesenWords
//
//  Created by Chuang Yu on 15/6/2018.
//  Copyright © 2018 Chuang Yu. All rights reserved.
//

import Cocoa
import Magnet

extension Character
{
    func unicodeScalarCodePoint() -> UInt32
    {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Register a listener for global key press events.
        // Using https://github.com/Clipy/Magnet
        guard let keyCombo = KeyCombo(keyCode: 11, carbonModifiers: 4352) else {
            return
        }
        let hotKey = HotKey(identifier: "CommandControlB", keyCombo: keyCombo, target: self, action: #selector(AppDelegate.tappedHotKey))
        hotKey.register()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        HotKeyCenter.shared.unregisterAll()
    }

    @objc func tappedHotKey() {
        // Simulate "cmd + c" that copys current selection to clipboard.
        let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        
        let cmdd = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: true)
        let cmdu = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: false)
        let cd = CGEvent(keyboardEventSource: src, virtualKey: 0x08, keyDown: true)
        let cu = CGEvent(keyboardEventSource: src, virtualKey: 0x08, keyDown: false)

        cd?.flags = CGEventFlags.maskCommand;
        
        let loc = CGEventTapLocation.cghidEventTap
        
        cmdd?.post(tap: loc)
        cd?.post(tap: loc)
        cu?.post(tap: loc)
        cmdu?.post(tap: loc)
        
        // Get string content from clipboard.
        guard let clipboardContent = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string)
            else { return }
        
        // Do the convertion
        let utf16ClipboardContent = clipboardContent.utf16
        var re: [UInt16] = []
        for char in utf16ClipboardContent {
            re.append(contentsOf: [char, 806, 786])
        }
        let s = String(utf16CodeUnits: re, count: re.count)
        
        // Write converted content to clipboard.
        NSPasteboard.general.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        NSPasteboard.general.setString(s, forType: .string)
        
        // Simulate "cmd + v" that pastes from clipboard.
        let vd = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: true)
        let vu = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: false)
        
        vd?.flags = CGEventFlags.maskCommand;
        
        cmdd?.post(tap: loc)
        vd?.post(tap: loc)
        vu?.post(tap: loc)
        cmdu?.post(tap: loc)
    }
}

