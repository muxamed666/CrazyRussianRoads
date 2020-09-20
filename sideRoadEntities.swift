//
//  sideRoadObjects.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 03.01.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


/*

 Hitbox class
 
*/

class hitbox
{
    var id : UInt?
    var debugCircle : SKShapeNode?
    var hitboxPosition : CGPoint?
    var hitboxRadius : CGFloat?
}


/*

 Here some base class for road-side ingame entities.
 Sadly, but Swift's object-oriented model is totally broken so here some s**tcode =(
 
*/

class sideRoadEntity
{
    //DATA
    
    //weak var, so it won't create reference cycle and memory leak
    weak var currentScene : GameScene? //Current scene pointer
    
    var interval : CGFloat = 1280; //distance between repeated objects
    var bounce : CGFloat = 146; //distance from screen edge to objects
    var randomlyAppears = false;
    
    var nodes = [SKSpriteNode?]()
    private var hitboxes = [hitbox]()
    var hitboxesCounter : UInt = 0
    var lastHitPosition : CGPoint?
    
    //METHODS
    
    
    /*
     
     Called when each frame is rendered
     Must be overloaded (like "virtual" in C++)!
     
    */
    
    func tick(velocity : CGFloat)
    {
        print("Tick must be overloaded by child class!")
    }
    
    
    /*
     
     Creates new hitbox, and adds it in hitbox array
     
    */
    
    func addHitbox(entityPosition : CGPoint, hitboxRelativePosition : CGPoint, hitboxSize : CGFloat)
    {
        let hpos = CGPoint(x: entityPosition.x + hitboxRelativePosition.x, y: entityPosition.y + hitboxRelativePosition.y)
        
        let damageDebugCircle = SKShapeNode(circleOfRadius: hitboxSize) // Size of Circle
        damageDebugCircle.position = hpos
        damageDebugCircle.strokeColor = SKColor.init(red: 1, green: 0, blue: 0, alpha: 0)
        damageDebugCircle.glowWidth = 1.0
        damageDebugCircle.fillColor = SKColor.clear
        damageDebugCircle.zPosition = 20 //TOP
        
        let newHitbox = hitbox()
        newHitbox.id = hitboxesCounter
        newHitbox.debugCircle = damageDebugCircle
        newHitbox.hitboxPosition = hpos
        newHitbox.hitboxRadius = hitboxSize
        
        currentScene!.addChild(newHitbox.debugCircle!) //Add debug shape to a scene
        hitboxesCounter = hitboxesCounter &+ 1; //&+ to allow overflow
        
        hitboxes.append(newHitbox)
    }
    
    
    /*
    
     Updates hitboxes positions, and checks for impacts
     Deletes offscreen hitboxes
     
    */
    
    func updateHitboxesAndCheckForImpacts(velocity : CGFloat) -> Bool
    {
        //visibility check
        for hbox in hitboxes
        {
            let viewportSize = currentScene!.sceneSizeHeight / 2
            
            if hbox.hitboxPosition!.y < -viewportSize
            {
                //delete hitbox
                hbox.debugCircle?.removeFromParent() //debug shape from screen
                
                if let index = hitboxes.index(where: {r in r.id == hbox.id})
                {
                    hitboxes.remove(at: index) //hotbox from array
                }
            }
        }
        
        //position update
        for hbox in hitboxes
        {
            hbox.hitboxPosition!.y = hbox.hitboxPosition!.y - velocity
            hbox.debugCircle?.position = hbox.hitboxPosition!
        }
        
        
        //impact check
        for hbox in hitboxes
        {
            guard let imp = currentScene?.carObject?.intersects(hbox.debugCircle!) else { continue; }
            
            if (imp)
            {
                lastHitPosition = hbox.hitboxPosition
                return true;
            }
        }
        
        return false;
    }
}


/*

 This class stores street lights
 
*/

class streetLight : sideRoadEntity
{
    //DATA
    var texture = SKTexture(image: #imageLiteral(resourceName: "fonar"));
    var size = CGSize(width: 206, height: 90);
    
    let baseTexture = SKTexture(image: #imageLiteral(resourceName: "fonarBase"))
    let baseSize = CGSize(width: 73, height: 90)
    
    let rightHitboxRelativePos = CGPoint(x: 64, y: 0)
    let leftHitboxRelativePos = CGPoint(x: -64, y: 0)
    let streetlightHitboxSize : CGFloat = 8
    
    //METHODS
    
    //constructor
    init(scene : GameScene?)
    {
        super.init()
        super.interval = 1280 //distance between street lights supports
        super.bounce  = 116
        super.currentScene = scene;
    }
    
    
    override func tick(velocity : CGFloat)
    {
        let streelightPause : CGFloat = super.interval
        var viewportSize = currentScene!.sceneSizeHeight / 2 //view?.bounds.height else { return; }
        let viewportSizeX = currentScene!.sceneSizeWidth / 2 //view?.bounds.width else { return; }
        var slNodesGeneratorPosition = viewportSize + streelightPause
        let streetlightTextureSize = size
        let streetligtBounce : CGFloat = super.bounce
        
        if(currentScene!.iphoneXAdaptationNeeded)
        {
            viewportSize *= currentScene!.iphoneXUpscaleRate
        }
        
        //if streetlight array is empty, generate and fill it with lines
        if super.nodes.count == 0
        {
            //filling screen with streetlights
            while (slNodesGeneratorPosition > -viewportSize)
            {
                //right side of the road
                let newNode = SKSpriteNode(texture: texture, size: streetlightTextureSize)
                newNode.position.x = viewportSizeX - streetligtBounce
                newNode.position.y = slNodesGeneratorPosition
                newNode.zPosition = 9
                super.nodes.append(newNode)
                currentScene!.addChild(newNode)
                
                //and streetlight base in another layer
                let baseNewNode = SKSpriteNode(texture: baseTexture, size: baseSize)
                baseNewNode.position.x = newNode.position.x + 64
                baseNewNode.position.y = newNode.position.y
                baseNewNode.zPosition = 6
                if (currentScene!.nightMode) { baseNewNode.zPosition = 5 } //kostyl
                super.nodes.append(baseNewNode)
                currentScene!.addChild(baseNewNode)
                
                addHitbox(entityPosition: newNode.position, hitboxRelativePosition: rightHitboxRelativePos, hitboxSize: streetlightHitboxSize)
                
                
                //on left side of road
                let newNodeLeft = SKSpriteNode(texture: texture, size: streetlightTextureSize)
                
                newNodeLeft.position.x = -viewportSizeX + streetligtBounce
                newNodeLeft.position.y = slNodesGeneratorPosition - (streelightPause / 2)
                newNodeLeft.zRotation = 3.1415
                newNodeLeft.zPosition = 9
                super.nodes.append(newNodeLeft)
                currentScene!.addChild(newNodeLeft)
                
                //and streetlight base in another layer
                let baseNewNodeLeft = SKSpriteNode(texture: baseTexture, size: baseSize)
                baseNewNodeLeft.position.x = newNodeLeft.position.x - 64
                baseNewNodeLeft.position.y = newNodeLeft.position.y
                baseNewNodeLeft.zPosition = 6
                if (currentScene!.nightMode) { baseNewNodeLeft.zPosition = 5 } //kostyl
                super.nodes.append(baseNewNodeLeft)
                currentScene!.addChild(baseNewNodeLeft)
                
                addHitbox(entityPosition: newNodeLeft.position, hitboxRelativePosition: leftHitboxRelativePos, hitboxSize: streetlightHitboxSize)
                
                //shadowing for night mode
                if currentScene!.nightMode
                {
                    newNode.color = .black
                    newNode.colorBlendFactor = 0.75
                    newNodeLeft.color = .black
                    newNodeLeft.colorBlendFactor = 0.75
                    //baseNewNode.color = .black
                    //baseNewNode.colorBlendFactor = 0.65
                    //baseNewNodeLeft.color = .black
                    //baseNewNodeLeft.colorBlendFactor = 0.65
                }
                
                
                slNodesGeneratorPosition -= streelightPause
            }
            
            return
        }
        
        //remove streetlight that goes off the screen
        for streetlight in super.nodes
        {
            guard let currentStreetlightY = streetlight?.position.y else { continue; }
            if(currentStreetlightY < ((-1*viewportSize)-streetlightTextureSize.height))
            {
                //line?.position.y = viewportSize + markupLineSize.height
                streetlight?.removeFromParent()
                
                if let index = super.nodes.index(of: streetlight)
                {
                    super.nodes.remove(at: index)
                }
            }
        }
        
        //move all streetlights down on screen, subtract car velocity from them
        for streetlight in super.nodes
        {
            guard let currentStreetlightY = streetlight?.position.y else { continue; }
            streetlight?.position.y = currentStreetlightY - velocity
        }
        
        //insert new streetlights in array
        guard let upperStreetlightPosition = super.nodes[0]?.position.y else { return }
        if(upperStreetlightPosition < viewportSize)
        {
            //right side of road
            let newNode = SKSpriteNode(texture: texture, size: streetlightTextureSize)
            newNode.position.x = viewportSizeX - streetligtBounce
            newNode.position.y = viewportSize + streelightPause
            newNode.zPosition = 9
            super.nodes.insert(newNode, at: 0)
            currentScene!.addChild(newNode)

            //and streetlight base in another layer
            let baseNewNode = SKSpriteNode(texture: baseTexture, size: baseSize)
            baseNewNode.position.x = newNode.position.x + 64
            baseNewNode.position.y = newNode.position.y
            baseNewNode.zPosition = 6
            if (currentScene!.nightMode) { baseNewNode.zPosition = 5 } //kostyl
            super.nodes.append(baseNewNode)
            currentScene!.addChild(baseNewNode)

            addHitbox(entityPosition: newNode.position, hitboxRelativePosition: rightHitboxRelativePos, hitboxSize: streetlightHitboxSize)
            
            
            //left side of road
            let newNodeLeft = SKSpriteNode(texture: texture, size: streetlightTextureSize)
            newNodeLeft.position.x = -viewportSizeX + streetligtBounce
            newNodeLeft.position.y = viewportSize + (streelightPause / 2)
            newNodeLeft.zRotation = 3.1415
            newNodeLeft.zPosition = 9
            super.nodes.insert(newNodeLeft, at: 1)
            currentScene!.addChild(newNodeLeft)
            
            //and streetlight base in another layer
            let baseNewNodeLeft = SKSpriteNode(texture: baseTexture, size: baseSize)
            baseNewNodeLeft.position.x = newNodeLeft.position.x - 64
            baseNewNodeLeft.position.y = newNodeLeft.position.y
            baseNewNodeLeft.zPosition = 6
            if (currentScene!.nightMode) { baseNewNodeLeft.zPosition = 5 } //kostyl
            super.nodes.append(baseNewNodeLeft)
            currentScene!.addChild(baseNewNodeLeft)
            
            addHitbox(entityPosition: newNodeLeft.position, hitboxRelativePosition: leftHitboxRelativePos, hitboxSize: streetlightHitboxSize)
            
            //shadowing for night mode
            if currentScene!.nightMode
            {
                newNode.color = .black
                newNode.colorBlendFactor = 0.75
                newNodeLeft.color = .black
                newNodeLeft.colorBlendFactor = 0.75
                //baseNewNode.color = .black
                //baseNewNode.colorBlendFactor = 0.65
                //baseNewNodeLeft.color = .black
                //baseNewNodeLeft.colorBlendFactor = 0.65
            }
            
        }
    }
}


/*
 
 This class stores foliage objects

*/

class foliages : sideRoadEntity
{
    
    //DATA
    var size = CGSize(width: 164, height: 164);
    private var foliageTextures = [SKTexture]()
    private var foliageTexturesWinter = [SKTexture]()
    private var foliageSpawnerTimeout : Int = 0
    let hitboxSize : CGFloat = 8
    let hitboxRelativePosRight = CGPoint(x: -20, y: 0);
    let hitboxRelativePosLeft = CGPoint(x: 20, y: 0);
    
    //METHODS
    
    //constructor
    init(scene : GameScene?)
    {
        super.init()
        super.randomlyAppears = true
        super.bounce = 23
        super.currentScene = scene;
        
        //Load foliage textures
        foliageTextures.append(SKTexture(image: #imageLiteral(resourceName: "fooliage_1")))
        foliageTextures.append(SKTexture(image: #imageLiteral(resourceName: "fooliage_2")))
        foliageTextures.append(SKTexture(image: #imageLiteral(resourceName: "fooliage_3")))
        
        foliageTexturesWinter.append(SKTexture(image: #imageLiteral(resourceName: "foliage_winter_1")))
        foliageTexturesWinter.append(SKTexture(image: #imageLiteral(resourceName: "foliage_winter_2")))
        foliageTexturesWinter.append(SKTexture(image: #imageLiteral(resourceName: "foliage_winter_1")))
    }
    
    
    /*
     
     Update foliage.
     Spawn new foliage with some chance
     Delete all foliage that goes offscreen
     Move all foliage that is on screen with speed
     
    */
    
    override func tick(velocity : CGFloat)
    {
        var viewportSize = currentScene!.sceneSizeHeight / 2 //view?.bounds.height else { return; }
        let viewportWidth = currentScene!.sceneSizeWidth / 2 //view?.bounds.width else { return; }
        let treeTextureSize = self.size
        
        if(currentScene!.iphoneXAdaptationNeeded) { viewportSize *= currentScene!.iphoneXUpscaleRate; }
        
        //spawn new three with some chance
        let chance = arc4random_uniform(100)
        
        //spawner timout decrement
        if(foliageSpawnerTimeout > 0)
        {
            foliageSpawnerTimeout -= 1
        }
        
        if(currentScene!.winterMode) { bounce = 0; }
        
        //use 1% chance of tree spawn on right shoulder of road
        if (chance == 32 && foliageSpawnerTimeout == 0)
        {
            //get random three texture
            let textureIndex : Int = Int(arc4random_uniform(3))
            let xPosCorrection = CGFloat(Int(arc4random_uniform(20)) - 10)
            var texture = foliageTextures[textureIndex]
            
            if currentScene!.winterMode
            {
                let winterTextureIndex = Int(arc4random_uniform(2))
                texture = foliageTexturesWinter[winterTextureIndex]
            }
            
            //create new node
            let newNode = SKSpriteNode(texture: texture, size: treeTextureSize)
            newNode.position.y = viewportSize + treeTextureSize.height
            newNode.position.x = viewportWidth + bounce + xPosCorrection
            newNode.zPosition = 9
            
            //add new node
            super.nodes.append(newNode)
            currentScene!.addChild(newNode)
            
            addHitbox(entityPosition: newNode.position, hitboxRelativePosition: hitboxRelativePosRight, hitboxSize: hitboxSize)
            
            //shadowing for night mode
            if currentScene!.nightMode
            {
                newNode.color = .black
                newNode.colorBlendFactor = 0.75
            }
            
            //set some timeout (in frames)
            foliageSpawnerTimeout += 0
        }
        
        //use 1% chance of spawn on left shoulder of road
        if (chance == 64 && foliageSpawnerTimeout == 0)
        {
            //get random three texture
            let textureIndex : Int = Int(arc4random_uniform(3))
            let xPosCorrection = CGFloat(Int(arc4random_uniform(20)) - 10)
            var texture = foliageTextures[textureIndex]
            
            if currentScene!.winterMode
            {
                let winterTextureIndex = Int(arc4random_uniform(2))
                texture = foliageTexturesWinter[winterTextureIndex]
            }
            
            //create new node
            let newNode = SKSpriteNode(texture: texture, size: treeTextureSize)
            newNode.position.y = viewportSize + treeTextureSize.height
            newNode.position.x = -viewportWidth - bounce + xPosCorrection
            newNode.zPosition = 9
            
            //add new node
            super.nodes.append(newNode)
            currentScene!.addChild(newNode)
            
            addHitbox(entityPosition: newNode.position, hitboxRelativePosition: hitboxRelativePosLeft, hitboxSize: hitboxSize)
            
            //shadowing for night mode
            if currentScene!.nightMode
            {
                newNode.color = .black
                newNode.colorBlendFactor = 0.75
            }
            
            //set some timeout (in frames)
            foliageSpawnerTimeout += 0
        }
        
        //Delete all foliage that are offscreen
        //remove line that goes off the screen
        for foliage in super.nodes
        {
            guard let currentY = foliage?.position.y else { continue; }
            if(currentY < ((-1*viewportSize)-treeTextureSize.height))
            {
                foliage?.removeFromParent()
                
                if let index = super.nodes.index(of: foliage)
                {
                    super.nodes.remove(at: index)
                }
            }
        }
        
        //Move all foliage with car velocity
        for foliage in super.nodes
        {
            guard let currentY = foliage?.position.y else { continue; }
            foliage?.position.y = currentY - velocity
        }
    }
    
}


/*
 
 This class stores snowbanks for winter mode
 
*/

class snowBanks : sideRoadEntity
{
    var leftBankTexture : SKTexture
    var rightBankTexture : SKTexture
    let bankSize : CGSize = CGSize(width: 120, height: 3000)
    
    //constructor
    init(scene : GameScene?)
    {
        //Load banks textures
        leftBankTexture = SKTexture(image: #imageLiteral(resourceName: "left_snow"))
        rightBankTexture = SKTexture(image: #imageLiteral(resourceName: "right_snow"))
        
        leftBankTexture.preload { }
        rightBankTexture.preload { }
        
        //load superclass constuctor
        super.init()
        super.randomlyAppears = false
        super.bounce = 135
        super.currentScene = scene;
        super.interval = 3000
    }
    
    override func tick(velocity: CGFloat)
    {
        var viewportSize = currentScene!.sceneSizeHeight / 2
        let viewportWidth = currentScene!.sceneSizeWidth / 2
         if(currentScene!.iphoneXAdaptationNeeded) { viewportSize *= currentScene!.iphoneXUpscaleRate; }
        
        //generate on start
        if super.nodes.count == 0
        {
            let newNodeRight = SKSpriteNode(texture: self.rightBankTexture)
            newNodeRight.position.x = viewportWidth - super.bounce
            newNodeRight.position.y = 0
            newNodeRight.zPosition = 5
            newNodeRight.size = bankSize
            
            nodes.append(newNodeRight)
            currentScene?.addChild(newNodeRight)
            
            let newNodeLeft = SKSpriteNode(texture: self.leftBankTexture)
            newNodeLeft.position.x = -viewportWidth + super.bounce
            newNodeLeft.position.y = 0
            newNodeLeft.zPosition = 5
            newNodeLeft.size = bankSize
            
            nodes.append(newNodeLeft)
            currentScene?.addChild(newNodeLeft)
        }
        
        //add new banks
        if nodes.last!!.position.y <= CGFloat(0)
        {
            let newNodeRight = SKSpriteNode(texture: self.rightBankTexture)
            newNodeRight.position.x = viewportWidth - super.bounce
            newNodeRight.position.y = nodes.last!!.position.y + bankSize.height
            newNodeRight.zPosition = 5
            newNodeRight.size = bankSize
            
            let newNodeLeft = SKSpriteNode(texture: self.leftBankTexture)
            newNodeLeft.position.x = -viewportWidth + super.bounce
            newNodeLeft.position.y = nodes.last!!.position.y + bankSize.height
            newNodeLeft.zPosition = 5
            newNodeLeft.size = bankSize
            
            nodes.append(newNodeRight)
            currentScene?.addChild(newNodeRight)
            
            nodes.append(newNodeLeft)
            currentScene?.addChild(newNodeLeft)
        }
        
        //Delete all banks that are offscreen
        for bank in super.nodes
        {
            guard let currentY = bank?.position.y else { continue; }
            if(currentY < ((-1*viewportSize)-bank!.size.height))
            {
                bank?.removeFromParent()
                
                if let index = super.nodes.index(of: bank)
                {
                    super.nodes.remove(at: index)
                }
            }
        }
        
        //Move all banks with car velocity
        for bank in super.nodes
        {
            guard let currentY = bank?.position.y else { continue; }
            bank?.position.y = currentY - velocity
        }
    }
    
}
