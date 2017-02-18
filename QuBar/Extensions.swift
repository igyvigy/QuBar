//
//  Extensions.swift
//  QuBar
//
//  Created by Andrii Narinian on 2/15/17.
//  Copyright © 2017 Andrii. All rights reserved.
//

import Foundation

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
