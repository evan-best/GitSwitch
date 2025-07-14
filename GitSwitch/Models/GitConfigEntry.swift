//
//  GitConfigEntry.swift
//  GitSwitch
//
//  Created by Evan Best on 2025-07-14.
//

import Foundation

struct GitConfigEntry: Identifiable {
    var id: String { key + origin }
    let key: String
    let value: String
    let origin: String
}
