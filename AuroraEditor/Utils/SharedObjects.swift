//
//  SharedObjects.swift
//  AuroraEditor
//
//  Created by Wesley de Groot on 05/08/2022.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

class SharedObjects: ObservableObject {
    public static let shared: SharedObjects = .init()

    @Published
    var caretPos: CursorLocation = .init(line: 0, column: 0)

    init() { }
}