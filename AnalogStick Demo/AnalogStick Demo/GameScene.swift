//
//  GameScene.swift
//
//  Created by Dmitriy Mitrophanskiy on 28.09.14.
//  Copyright (c) 2014 Dmitriy Mitrophanskiy. All rights reserved.
//
import SpriteKit

var player: SKSpriteNode?

class GameScene: SKScene {
    let joystick = AnalogJoystick(diameter: 200, colors: (UIColor.blue, UIColor.yellow))
    let rightJoystick = AnalogJoystick(diameter: 200, colors: (UIColor.white, UIColor.black))
  
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        backgroundColor = UIColor.white
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        
        //Player
        player = self.childNode(withName: "player") as? SKSpriteNode
        
        //JOYSTICKS
        
        joystick.name = "joystick"
        rightJoystick.name = "rightjoystick"
        rightJoystick.shootStick = true
        
        //MARK: Handlers begin
        
        joystick.beginHandler = { [weak self] in
        }
        
        joystick.trackingHandler = { [weak self] data in
            guard self?.player != nil else { return }
            self?.player?.position = CGPoint(x: (self?.player?.position.x)! + (data.velocity.x * 0.12), y: (self?.player?.position.y)! + (data.velocity.y * 0.12))
        }
        
        joystick.stopHandler = { [weak self] in
            let joysticknode = self?.camera?.childNode(withName: "joystick")
            joysticknode?.removeFromParent()
        }
        
        rightJoystick.beginHandler = { [weak self] in
            if Weapon.timer == nil {
                Weapon.startTimer()
                
            }
        }
        
        rightJoystick.trackingHandler = { [weak self] Data in
            guard self?.player != nil else { return }
            
            
            if Weapon.cooldown == 0 {
                self?.shoot(projectileNamed: "f2", inDirection: Data.velocity)
            }
            //self?.player?.zRotation = Data.angular
            
        }
        
        rightJoystick.stopHandler =  { [weak self] in
            let joysticknode = self?.camera?.childNode(withName: "rightjoystick")
            joysticknode?.removeFromParent()
            
        }
        
        
        //MARK: Handlers end
        let selfHeight = frame.height
        let btnsOffset: CGFloat = 10
        let btnsOffsetHalf = btnsOffset / 2
        let joystickSizeLabel = SKLabelNode(text: "Joysticks Size:")
        

        view.isMultipleTouchEnabled = true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ((touches.first?.location(in: self.camera!).x)! > 0 as CGFloat), (self.camera?.childNode(withName: "rightjoystick") == nil) {
            rightJoystick.position = touches.first!.location(in: self.camera!)
            self.camera?.addChild(rightJoystick)
        }
        if ((touches.first?.location(in: self.camera!).x)! < 0 as CGFloat), (self.camera?.childNode(withName: "joystick") == nil) {
            joystick.position = touches.first!.location(in: self.camera!)
            self.camera?.addChild(joystick)
        }
        
        let handledTouches = handleTouches(touches: touches)
        joystick.touchesBegan(handledTouches.leftTouches, with: event)
        rightJoystick.touchesBegan(handledTouches.rightTouches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let handledTouches = handleTouches(touches: touches)
        
        if self.camera?.childNode(withName: "rightjoystick") != nil {
            rightJoystick.touchesMoved(handledTouches.rightTouches, with: event)
        }
        
        if self.camera?.childNode(withName: "joystick") != nil {
            joystick.touchesMoved(handledTouches.leftTouches, with: event)
        }
        
        //let handledTouches = handleTouches(touches: touches)
        // joystick.touchesMoved(handledTouches.leftTouches, with: event)
        //  rightJoystick.touchesMoved(handledTouches.rightTouches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if ((touches.first?.location(in: self.camera!).x)! > 0 as CGFloat), (self.camera?.childNode(withName: "rightjoystick") != nil) {
            rightJoystick.position = touches.first!.location(in: self.camera!)
            let handledTouches = handleTouches(touches: touches)
            rightJoystick.touchesCancelled(handledTouches.rightTouches, with: event)
            // rightJoystick.removeFromParent()
        }
        if ((touches.first?.location(in: self.camera!).x)! < 0 as CGFloat), (self.camera?.childNode(withName: "joystick") != nil) {
            joystick.position = touches.first!.location(in: self.camera!)
            let handledTouches = handleTouches(touches: touches)
            joystick.touchesCancelled(handledTouches.leftTouches, with: event)
            //joystick.removeFromParent()
        }
        
        //        let handledTouches = handleTouches(touches: touches)
        //        joystick.touchesCancelled(handledTouches.leftTouches, with: event)
        //        rightJoystick.touchesCancelled(handledTouches.rightTouches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if ((touches.first?.location(in: self.camera!).x)! > 0 as CGFloat), (self.camera?.childNode(withName: "rightjoystick") != nil) {
            rightJoystick.position = touches.first!.location(in: self.camera!)
            let handledTouches = handleTouches(touches: touches)
            rightJoystick.touchesEnded(handledTouches.rightTouches, with: event)
            rightJoystick.removeFromParent()
        }
        if ((touches.first?.location(in: self.camera!).x)! < 0 as CGFloat), (self.camera?.childNode(withName: "joystick") != nil) {
            joystick.position = touches.first!.location(in: self.camera!)
            let handledTouches = handleTouches(touches: touches)
            joystick.touchesEnded(handledTouches.leftTouches, with: event)
            joystick.removeFromParent()
        }
        
        //        let handledTouches = handleTouches(touches: touches)
        //        joystick.touchesEnded(handledTouches.leftTouches, with: event)
        //        rightJoystick.touchesEnded(handledTouches.rightTouches, with: event)
    }
    
    private func handleTouches(touches: Set<UITouch>) -> (leftTouches: Set<UITouch>, rightTouches: Set<UITouch>){
        var leftTouches = Set<UITouch>()
        var rightTouches = Set<UITouch>()
        
        for touch in touches {
            if touch.location(in: self.camera!).x > 0 {
                rightTouches.insert(touch)
            }
            
            if touch.location(in: self.camera!).x < 0 {
                leftTouches.insert(touch)
            }
        }
        return (leftTouches, rightTouches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}

extension UIColor {
    
    static func random() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
}
