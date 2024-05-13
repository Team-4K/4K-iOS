//
//  gamPrint.swift
//  GAM
//
//  Created by Jungbin on 5/13/24.
//

import Foundation

func gamPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if !Release
        debugPrint(items, separator: separator, terminator: terminator)
    #endif
}
