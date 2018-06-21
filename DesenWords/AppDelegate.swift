//
//  AppDelegate.swift
//  DesenWords
//
//  Created by Chuang Yu on 15/6/2018.
//  Copyright © 2018 Chuang Yu. All rights reserved.
//

import Cocoa
import Magnet

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
         simulateCopy()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            // Get string content from clipboard.
            let pasteboard = NSPasteboard.general
            guard let clipboardContent = pasteboard.pasteboardItems?.first?.string(forType: .string)
                else { return }
            
            // Do the convertion
            let utf16ClipboardContent = clipboardContent.utf16
            var convertedChars: [UInt16] = [32]
            convertedChars.append(contentsOf: randomVowel())
            
            for char in utf16ClipboardContent {
                var convertedChar = [char]
                convertedChar.append(contentsOf: randomVowel())
                convertedChars.append(contentsOf: convertedChar)
            }
            
            convertedChars.append(contentsOf: randomVowel())
            
            let convertedString = String(utf16CodeUnits: convertedChars, count: convertedChars.count)
            
            // Write converted content to clipboard.
            pasteboard.clearContents()
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(convertedString, forType: .string)
            
            simulatePaste()
        }
    }
}

func simulateCopy() {
    // Simulate "cmd + c" that copys current selection to clipboard.
    let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
    
    let cmdd = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: true)
    let cmdu = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: false)
    let cd = CGEvent(keyboardEventSource: src, virtualKey: 0x08, keyDown: true)
    let cu = CGEvent(keyboardEventSource: src, virtualKey: 0x08, keyDown: false)
    
    let loc = CGEventTapLocation.cghidEventTap
    
    cd?.flags = CGEventFlags.maskCommand;

    cmdd?.post(tap: loc)
    cd?.post(tap: loc)
    cu?.post(tap: loc)
    cmdu?.post(tap: loc)
}

func simulatePaste() {
    // Simulate "cmd + v" that pastes from clipboard.
    let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
    
    let cmdd = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: true)
    let cmdu = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: false)
    let vd = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: true)
    let vu = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: false)
    
    let loc = CGEventTapLocation.cghidEventTap

    vd?.flags = CGEventFlags.maskCommand;
    
    cmdd?.post(tap: loc)
    vd?.post(tap: loc)
    vu?.post(tap: loc)
    cmdu?.post(tap: loc)
}

let vowels: [[UInt16]] = [
    [806, 786],
    [8405, 3865],
    [8417, 3902],
    [8400, 805],
    [7619, 808],
    [3968, 3893],
    [3964, 3865],
    [3962, 3426]
]
func randomVowel() -> [UInt16] {
    let randomIndex = Int(arc4random_uniform(UInt32(vowels.count)))
    return vowels[randomIndex]
}

