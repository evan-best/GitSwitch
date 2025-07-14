//
//  AppDelegate.swift
//  GitSwitch
//
//  Created by Evan Best on 2025-07-14.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "person.crop.circle.badge.checkmark", accessibilityDescription: "GitSwitch")

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open GitSwitch", action: #selector(openApp), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    @objc func openApp() {
        NSApp.activate(ignoringOtherApps: true)
    }
}
