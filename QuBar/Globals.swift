//
//  Globals.swift
//  QuBar
//
//  Created by Andrii Narinian on 9/20/17.
//  Copyright © 2017 Andrii. All rights reserved.
//

import UIKit

enum direction {
    case left, right, up, down
}

var isGoingToRemainSolid = true
var isHorisontalRotationLocked = true
var axisBidirectionalOffset: CGFloat = 0.7
var cubePhysicsBodyAngularVelocityBaseline: Float = 0.15
