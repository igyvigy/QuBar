//
//  QuBar.swift
//  QuBar
//
//  Created by Andrii Narinian on 2/15/17.
//  Copyright © 2017 Andrii. All rights reserved.
//

import SceneKit

protocol QuBarDelegate: class {
    func collapse()
    func raize()
    func didFadeIn()
    func willFadeOut()
    func didRotateToface(withIndex index: Int, dir: direction?)
}

class QuBar: SCNView {
    
    weak var quBarDelegate: QuBarDelegate?
    var isCollapsed = false
    var isReleasedToFly = false
    var cube: SCNNode!
    var isSoundEnabled = false
    let orientationFaces = [
        SCNVector4(x: 0.0, y: -0.0, z: 0.0, w: 1.0),//1
        SCNVector4(x: 0.0, y: -0.706825197, z: 0.0, w: 0.707388222),//2
        SCNVector4(x: 0.0, y: -0.999999702, z: 0.0, w: 0.000796274282),//3
        SCNVector4(x: 0.0, y: 0.70795089, z: 0.0, w: 0.706261635),//4
        SCNVector4(x: 0.706825256, y: 0.0, z: 0.0, w: 0.707388222),//5
        SCNVector4(x: 0.70795089, y: 0.0, z: 0.0, w: -0.706261635)//6
    ]
    
    var currentOrientationFaceIndex: Int?
    let clickSoundAction = SCNAction.playAudio(SCNAudioSource(named: "art.scnassets/sounds/plastic_tweezers_close.mp3")!, waitForCompletion: false)
    var face1 = SCNVector3Zero
    var face2 = SCNVector3Zero
    var face3 = SCNVector3Zero
    var face4 = SCNVector3Zero
    var face5 = SCNVector3Zero
    var face6 = SCNVector3Zero
    
    var speedRegisterArray = [CGFloat]()
    var registeredSpeed: CGFloat {
        set{
            speedRegisterArray.append(newValue)
            if speedRegisterArray.count > 3 { speedRegisterArray.removeFirst() }
        }
        get{
            return speedRegisterArray.sorted(by: { $0 > $1 }).first ?? 0.0
        }
    }
    var speedVector: CGVector?
    var touchMovesCount = 0
    var isTouchTooLongToBeSwipe: Bool{
        return touchMovesCount > 10
    }
    var lastPrettyCloseIndex: Int?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        scene = SCNScene(named: "art.scnassets/level.scn")!
        cube = scene?.rootNode.childNode(withName: "cube", recursively: true)
        var materials = [SCNMaterial]()
        delegate = self
        for face in 1...6 {
            let image = UIImage(named: "\(face)")
            let material = SCNMaterial()
            material.diffuse.contents = image
            materials.append(material)
        }
        cube.geometry?.materials = materials
        let joint = SCNPhysicsBallSocketJoint(body: cube.physicsBody!, anchor: SCNVector3(0, 0, 0))
        scene?.physicsWorld.addBehavior(joint)
    }
    
    func rotate(toFaceIndex index: Int, dir: direction?) {
        let face = orientationFaces[index]
        if let copy = cube.copy() as? SCNNode{
            copy.orientation = face
            if index != 1 && index != 3 {
                cube.runAction(SCNAction.sequence([SCNAction.rotateTo(x: CGFloat(copy.eulerAngles.x), y: CGFloat(copy.eulerAngles.y), z: CGFloat(copy.eulerAngles.z), duration: 0.3, usesShortestUnitArc: true), SCNAction.run({_ in
                    self.quBarDelegate?.didRotateToface(withIndex: index, dir: dir)
                })]))
            } else if index == 1 {
                cube.runAction(SCNAction.sequence([SCNAction.rotateTo(x: 0, y: -1.57079637, z: 0, duration: 0.3, usesShortestUnitArc: true), SCNAction.run({_ in
                    self.quBarDelegate?.didRotateToface(withIndex: index, dir: dir)
                    })]))
            } else if index == 3 {
                cube.runAction(SCNAction.sequence([SCNAction.rotateTo(x: 0, y: 1.57079637, z: 0, duration: 0.3, usesShortestUnitArc: true), SCNAction.run({_ in
                    self.quBarDelegate?.didRotateToface(withIndex: index, dir: dir)
                })]))
            }
        }
    }
    
    func shake(completion: @escaping () -> Void) {
        
    }
    
    func rotateToFace(withDirection dir: direction) {
        cube.physicsBody?.clearAllForces()
        cube.physicsBody?.angularVelocity = SCNVector4Zero
        switch dir {
        case .left:
            switch currentOrientationFaceIndex ?? 0 {
            case 0: rotate(toFaceIndex: 3, dir: dir)
            case 1: rotate(toFaceIndex: 0, dir: dir)
            case 2: rotate(toFaceIndex: 1, dir: dir)
            case 3: rotate(toFaceIndex: 2, dir: dir)
            case 4: rotate(toFaceIndex: 3, dir: dir)
            case 5: rotate(toFaceIndex: 3, dir: dir)
            default:break
            }
        case .right:
            switch currentOrientationFaceIndex ?? 0 {
            case 0: rotate(toFaceIndex: 1, dir: dir)
            case 1: rotate(toFaceIndex: 2, dir: dir)
            case 2: rotate(toFaceIndex: 3, dir: dir)
            case 3: rotate(toFaceIndex: 0, dir: dir)
            case 4: rotate(toFaceIndex: 1, dir: dir)
            case 5: rotate(toFaceIndex: 1, dir: dir)
            default:break
            }
        case .up:
            switch currentOrientationFaceIndex ?? 0 {
            case 0: rotate(toFaceIndex: 4, dir: dir)
            case 1: rotate(toFaceIndex: 4, dir: dir)
            case 2: rotate(toFaceIndex: 4, dir: dir)
            case 3: rotate(toFaceIndex: 4, dir: dir)
            case 4: rotate(toFaceIndex: 2, dir: dir)
            case 5: rotate(toFaceIndex: 0, dir: dir)
            default:break
            }
        case .down:
            switch currentOrientationFaceIndex ?? 0 {
            case 0: rotate(toFaceIndex: 5, dir: dir)
            case 1: rotate(toFaceIndex: 5, dir: dir)
            case 2: rotate(toFaceIndex: 5, dir: dir)
            case 3: rotate(toFaceIndex: 5, dir: dir)
            case 4: rotate(toFaceIndex: 0, dir: dir)
            case 5: rotate(toFaceIndex: 2, dir: dir)
            default:break
            }
        }
    }
    
    func stopRotating() {
        if isReleasedToFly {
            cube.transform = cube.presentation.transform
            cube.physicsBody?.angularVelocity = SCNVector4Zero
            cube.physicsBody?.clearAllForces()
        }
    }
    
    func reset(){
        cube?.removeAllActions()
        cube?.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.3))
        cube.physicsBody?.resetTransform()
    }
    
    func findNearestOrientationFaceIndex(offset: CGFloat = axisBidirectionalOffset) -> Int? {
        cube.transform = cube.presentation.transform
        face1 = cube.convertPosition(cube.childNode(withName: "face1", recursively: false)?.position ?? SCNVector3Zero, to: scene?.rootNode)
        face2 = cube.convertPosition(cube.childNode(withName: "face2", recursively: false)?.position ?? SCNVector3Zero, to: scene?.rootNode)
        face3 = cube.convertPosition(cube.childNode(withName: "face3", recursively: false)?.position ?? SCNVector3Zero, to: scene?.rootNode)
        face4 = cube.convertPosition(cube.childNode(withName: "face4", recursively: false)?.position ?? SCNVector3Zero, to: scene?.rootNode)
        face5 = cube.convertPosition(cube.childNode(withName: "face5", recursively: false)?.position ?? SCNVector3Zero, to: scene?.rootNode)
        face6 = cube.convertPosition(cube.childNode(withName: "face6", recursively: false)?.position ?? SCNVector3Zero, to: scene?.rootNode)
        
        if isValue(value: CGFloat(face1.x), nearEqualMarker: 0, withBidirectionalOffset: offset)
            &&
            isValue(value: CGFloat(face1.y), nearEqualMarker: 0, withBidirectionalOffset: offset)
            &&
            isValue(value: CGFloat(face1.z), nearEqualMarker: 0.494, withBidirectionalOffset: offset)
        {
            return 0
        }
        if isValue(value: CGFloat(face2.x), nearEqualMarker: 0, withBidirectionalOffset: offset)
            &&
            isValue(value: CGFloat(face2.y), nearEqualMarker: 0, withBidirectionalOffset: offset)
            &&
            isValue(value: CGFloat(face2.z), nearEqualMarker: 0.494, withBidirectionalOffset: offset)
        {
            return 1
        }

        if isValue(value: CGFloat(face3.x), nearEqualMarker: 0, withBidirectionalOffset: offset)
            &&
            isValue(value: CGFloat(face3.y), nearEqualMarker: 0, withBidirectionalOffset: offset)
            &&
            isValue(value: CGFloat(face3.z), nearEqualMarker: 0.494, withBidirectionalOffset: offset)
        {
            return 2
        }
        if isValue(value: CGFloat(face4.x), nearEqualMarker: 0, withBidirectionalOffset: offset)
            &&
            isValue(value: CGFloat(face4.y), nearEqualMarker: 0, withBidirectionalOffset: offset)
            &&
            isValue(value: CGFloat(face4.z), nearEqualMarker: 0.494, withBidirectionalOffset: offset)
        {
            return 3
        }
        if isValue(value: CGFloat(face5.x), nearEqualMarker: 0, withBidirectionalOffset: offset)
            &&
            isValue(value: CGFloat(face5.y), nearEqualMarker: 0, withBidirectionalOffset: offset)
            &&
            isValue(value: CGFloat(face5.z), nearEqualMarker: 0.494, withBidirectionalOffset: offset)
        {
            return 4
        }
        if isValue(value: CGFloat(face6.x), nearEqualMarker: 0, withBidirectionalOffset: offset)
            &&
            isValue(value: CGFloat(face6.y), nearEqualMarker: 0, withBidirectionalOffset: offset)
            &&
            isValue(value: CGFloat(face6.z), nearEqualMarker: 0.494, withBidirectionalOffset: offset)
        {
            return 5
        }
    return nil
    }
    
    func isValue(value: CGFloat, nearEqualMarker marker: CGFloat, withBidirectionalOffset offset: CGFloat) -> Bool {
        return (value > marker - offset/2 && value < marker + offset/2)
    }
    
    func fadeIn(isGoingToRemainSolid: Bool = false) {
        if let _ = cube.action(forKey: "fadeInAction") {
            return
        }
        if isGoingToRemainSolid {
            if isCollapsed {
                self.quBarDelegate?.didFadeIn()
            }
            return
        }
        if isCollapsed {
            cube.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 1),
            SCNAction.fadeOpacity(to: 0.4, duration: 0.5),
            SCNAction.run({_ in
                self.quBarDelegate?.didFadeIn()
            })
            ]), forKey: "fadeInAction")
        }
    }
    
    func fadeOut(isShowingButtons: Bool = true) {
        if let _ = cube.action(forKey: "fadeOutAction") {
            return
        }
        if isShowingButtons {
            quBarDelegate?.willFadeOut()
        }
        if let _ = cube.action(forKey: "fadeInAction") {
            cube.removeAction(forKey: "fadeInAction")
        }
        cube.runAction(SCNAction.fadeOpacity(to: 1.0, duration: 0.5), forKey: "fadeOutAction")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if !isSoundEnabled { isSoundEnabled = true }
        cube.physicsBody?.angularVelocity = SCNVector4Zero
        isReleasedToFly = false
        cube.transform = cube.presentation.transform
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isCollapsed {
            raize()
        } else {
            collapse()
        }
        if let index = findNearestOrientationFaceIndex() {
            rotate(toFaceIndex: index, dir: nil)
        }
    }
 
    fileprivate var prePanLoc: CGPoint?
    func pannerDidPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            touchMovesCount = 0
            prePanLoc = sender.location(in: self)
            if let _ = cube.action(forKey: "fadeInAction") {
                cube.removeAction(forKey: "fadeInAction")
            }
            fadeOut(isShowingButtons: false)
        case .changed:
            touchMovesCount += 1
            guard let preLoc = prePanLoc else {
                return
            }
            let xDif = sender.location(in: self).x - preLoc.x
            let yDif = sender.location(in: self).y - preLoc.y
            let distance = sqrt((xDif * xDif) + (yDif * yDif))
            registeredSpeed = distance
            if distance > 10 {
                speedVector = CGVector(dx: xDif, dy: yDif)
            }
            //angle = atg(move/distanceFromCube)
            let distanceFromCamera:CGFloat = 50
            let xAngle = atan(xDif/distanceFromCamera)
            let yAngle = atan(yDif/distanceFromCamera)
            cube.runAction(SCNAction.rotate(by: xAngle, around: SCNVector3(0,1,0), duration: 0.1))
            cube.runAction(SCNAction.rotate(by: yAngle, around: SCNVector3(1,0,0), duration: 0.1))
            cube.physicsBody?.resetTransform()
            prePanLoc = sender.location(in: self)
        case .ended:
            if registeredSpeed > 10 {
                if let vector = speedVector {
                    let distance:CGFloat = 50
                    let xAngle = atan(vector.dx/distance)
                    let yAngle = atan(vector.dy/distance)
                    if isTouchTooLongToBeSwipe {
                        cube.physicsBody?.applyTorque(SCNVector4(0, 1, 0, xAngle), asImpulse: true)
                        if !isHorisontalRotationLocked {
                            cube.physicsBody?.applyTorque(SCNVector4(1, 0, 0, yAngle), asImpulse: true)
                        }
                        isReleasedToFly = true
                    } else {
                        let xDif = vector.dx
                        let yDif = vector.dy
                        if abs(xDif) > abs(yDif) {
                            if xDif > 0 {
                                rotateToFace(withDirection: .left)
                            }
                            if xDif < 0 {
                                rotateToFace(withDirection: .right)
                            }
                        } else  {
                            if yDif > 0 {
                                if isHorisontalRotationLocked {
                                    rotate(toFaceIndex: currentOrientationFaceIndex ?? 0, dir: nil)
                                    collapse()
                                } else {
                                    rotateToFace(withDirection: .up)
                                }
                            }
                            if yDif < 0 {
                                if isHorisontalRotationLocked {
                                    shake {}
                                } else {
                                    rotateToFace(withDirection: .down)
                                }
                            }
                        }
                    }
                }
            } else {
                if let index = findNearestOrientationFaceIndex() {
                    rotate(toFaceIndex: index, dir: nil)
                }
            }
            prePanLoc = nil
            fadeIn(isGoingToRemainSolid: isGoingToRemainSolid)
        case .cancelled:
            print("pan cancelled")
        default: break
        }
    }
    
    func collapse() {
        quBarDelegate?.collapse()
        isCollapsed = !isCollapsed
        fadeIn(isGoingToRemainSolid: isGoingToRemainSolid)
    }
    
    func raize() {
        quBarDelegate?.raize()
        isCollapsed = !isCollapsed
        fadeOut()
    }
    
    func isItTimeToPlayPositionalClick() -> Bool {
        if let prettyCloseIndex = findNearestOrientationFaceIndex(offset: axisBidirectionalOffset) {
            if prettyCloseIndex == lastPrettyCloseIndex { return false }
            lastPrettyCloseIndex = prettyCloseIndex
            return true
        }
        return false
    }
}

extension QuBar: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        currentOrientationFaceIndex = findNearestOrientationFaceIndex()
        if isHorisontalRotationLocked {
            cube.orientation.x = cube.orientation.x*0.01
            cube.orientation.z = cube.orientation.z*0.01
        }
        if isSoundEnabled {
            if isItTimeToPlayPositionalClick() {
                scene?.rootNode.runAction(clickSoundAction)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        if (cube.physicsBody?.angularVelocity.w ?? 0 <= cubePhysicsBodyAngularVelocityBaseline) && isReleasedToFly {
            isReleasedToFly = false
            cube.physicsBody?.angularVelocity = SCNVector4Zero
            if let index = findNearestOrientationFaceIndex() {
                rotate(toFaceIndex: index, dir: nil)
            }
        }
    }
}
