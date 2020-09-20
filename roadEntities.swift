//
//  roadEntities.swift
//  Crazy Russian Road
//
//  Created by Muxa Mot on 14.09.2018.
//  Copyright © 2018 Muxa Mot. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit



// ROAD ENTITIES TEXTURE ATLAS OBJECT
let roadTextureAtlas = SKTextureAtlas(dictionary:
    [
     "rubleTexture" : #imageLiteral(resourceName: "rubleLogo"),
     "holeTexture_0": #imageLiteral(resourceName: "hole_1"),
     "holeTexture_1": #imageLiteral(resourceName: "hole_2"),
     "hatchTexture_0": #imageLiteral(resourceName: "hatch_closed"),
     "hatchTexture_1": #imageLiteral(resourceName: "hatch_open"),
     "hatchTexture_2": #imageLiteral(resourceName: "hatch_damaged"),
     "hatchTexture_3": #imageLiteral(resourceName: "hatch_broken"),
     "plankTexture": #imageLiteral(resourceName: "plank"),
     "speedbump_0": #imageLiteral(resourceName: "sb3"),
     "speedbump_1": #imageLiteral(resourceName: "sb1"),
     "speedbump_2": #imageLiteral(resourceName: "sb2"),
     "gradientTexture": #imageLiteral(resourceName: "gradient"),
     "powerups_0": #imageLiteral(resourceName: "superspeed"),
     "powerups_1": #imageLiteral(resourceName: "godmode"),
     "powerups_2": #imageLiteral(resourceName: "repairboost"),
     "pipeTexture" : #imageLiteral(resourceName: "pipeHole")
    ])

/*

 Specifies objects to be spawned on road
 Stores its proprties, sizes etc
 
*/

class roadEntity : Equatable
{
    /*
    
     This is base class for road entity.
     Road entity has
        - size
        - texture
        - impact type
        - impact properies
     
    */
    
    //DATA
    
    var texture : SKTexture
    var size : CGSize
    var position : CGPoint
    var isPoint : Bool
    var isHatch : Bool
    var isPlank : Bool = false
    var isPowerUps : Bool = false
    var isSpeedbump : Bool = false
    var isPipe : Bool = false
    var interactsOnlyWithWheels : Bool
    var isInteractable : Bool
    var damageDistance : CGFloat = 38.5
    var hitByWheel : Int = 0 //0 - None, 1 - LF, 2 - RF, 3 - LR, 4 - RR
    var damageDebugCircle : SKShapeNode
    
    var sprite : SKSpriteNode
    
    //METHODS
    
    /*
    
     Base class constructor
     
    */
    
    init(texture : SKTexture, size : CGSize, position : CGPoint, isPoint : Bool, isHatch : Bool, wheelsOnly : Bool, isInteractable : Bool)
    {
        self.texture = texture
        self.size = size
        self.position = position
        self.isPoint = isPoint
        self.isHatch = isHatch
        self.interactsOnlyWithWheels = wheelsOnly
        self.isInteractable = isInteractable
        
        sprite = SKSpriteNode(texture: self.texture, size: self.size)
        sprite.position = self.position
        sprite.zPosition = 4
        
        damageDebugCircle = SKShapeNode(circleOfRadius: damageDistance) // Size of Circle
        damageDebugCircle.position = self.position
        damageDebugCircle.strokeColor = SKColor.red
        damageDebugCircle.glowWidth = 1.0
        damageDebugCircle.fillColor = SKColor.clear
        damageDebugCircle.zPosition = 20 //TOP
    }
    
    
    /*
    
     Overload operator==
     
    */
    
    static func == (lhs: roadEntity, rhs: roadEntity) -> Bool
    {
        return lhs.getSpriteNode() == rhs.getSpriteNode()
    }
    
    
    /*
    
     Returns Sprite Node object
     
    */
    
    public func getSpriteNode() -> SKSpriteNode
    {
        return sprite;
    }
    
    
    /*
    
     Returns debug shape
     
    */
    
    public func getDebugCircle() -> SKShapeNode
    {
        return damageDebugCircle;
    }
    
    
    /*
    
     Slides down object
     
    */
    
    public func tickDown(velocity : CGFloat)
    {
        sprite.position.y -= velocity
        damageDebugCircle.position.y -= velocity
    }
    
    
    /*
    
     Screen bounds check
     
    */
    
    public func isInScreenBounds(bounds : CGFloat) -> Bool
    {
        let currentY = sprite.position.y 
        if(currentY < ((-1*bounds)-self.size.height))
        {
            return false
        }
        
        return true
    }
    
    
    /*
    
     Does visual animation on entity when interacting
     
    */
    
    private func visualInteractHandler()
    {
        if(self.isHatch)
        {
            let hatch = self as! hatchEntity
            if(hatch.hatchType == 2 && hatch.damagedHatchWillBreak)
            {
                hatch.sprite.texture = roadTextureAtlas.textureNamed("hatchTexture_3")
                //... hatchTextures[3]
            }
            else if (hatch.hatchType == 2 && !hatch.damagedHatchWillBreak)
            {
                return;
            }
        }
        
        
        if(self.isPoint || self.isPowerUps)
        {
            self.sprite.run(SKAction(named: "disappear")!)
        }
        else
        {
            sharedMethodsStorage.makeBzzzzByVibrator()
            //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
    }

    
    /*
    
     Intersecting test
     Arguments : center point of each wheel
     
    */
    
    public func collides(Car : CGPoint, LF : CGPoint, RF : CGPoint, LR : CGPoint, RR : CGPoint) -> Bool
    {
        if(!isInteractable){ return false }

        if(interactsOnlyWithWheels)
        {
            //get absolute coords of hatch center
            let selfCenter = self.sprite.position
            //get vector length from wheel center to hatch center
            var radiusVector = sqrt((LF.x - selfCenter.x)*(LF.x - selfCenter.x)
                + (LF.y - selfCenter.y)*(LF.y - selfCenter.y))
            //if vect length is less or equal of damage distance - register damage
            //damage distance is overrideable by child classed
            if (radiusVector <= self.damageDistance)
            {
                //NSLog("Detected collision by Left Front Wheel")
                //NSLog("Hit distance = " + String(Float(radiusVector)))
                visualInteractHandler()
                hitByWheel = 1
                isInteractable = false // do not detecting hits anymore
                return true;
            }
            
            //RF
            radiusVector = sqrt((RF.x - selfCenter.x)*(RF.x - selfCenter.x)
                + (RF.y - selfCenter.y)*(RF.y - selfCenter.y))
            if (radiusVector <= self.damageDistance)
            {
                visualInteractHandler()
                hitByWheel = 2
                isInteractable = false // do not detecting hits anymore
                return true;
                //debug test only
            }
            
            //LR
            radiusVector = sqrt((LR.x - selfCenter.x)*(LR.x - selfCenter.x)
                + (LR.y - selfCenter.y)*(LR.y - selfCenter.y))
            if (radiusVector <= self.damageDistance)
            {
                visualInteractHandler()
                hitByWheel = 3
                isInteractable = false // do not detecting hits anymore
                return true;
                //debug test only
            }
            
            //RR
            radiusVector = sqrt((RR.x - selfCenter.x)*(RR.x - selfCenter.x)
                + (RR.y - selfCenter.y)*(RR.y - selfCenter.y))
            if (radiusVector <= self.damageDistance)
            {
                visualInteractHandler()
                hitByWheel = 4
                isInteractable = false // do not detecting hits anymore
                return true;
                //debug test only
            }
        }
        else
        {
            let selfCenter = self.sprite.position
            var carSphere = Car
            carSphere.y = LF.y
            let radiusVector = sqrt((carSphere.x - selfCenter.x)*(carSphere.x - selfCenter.x)
                + (carSphere.y - selfCenter.y)*(carSphere.y - selfCenter.y))
            
            if (radiusVector <= 128)
            {
                visualInteractHandler()
                isInteractable = false;
                return true;
                //debug test only
            }
        }
        
        return false
    }
}


/*

 Class stores rubles objects, with its unique properties
 Child class from generic road entity class
 
*/

class rubleEntity : roadEntity
{
    //DATA
    
    
    var pointsValue : Int = 0; //value

    //METHODS
    
    init(screenHeight : CGFloat, roadWidth : CGFloat, rubleMin : UInt, rubleMax : UInt)
    {
        // we randomly store MIN to MAX points in one ruble by default
        pointsValue = Int(arc4random_uniform(UInt32(rubleMax)) + UInt32(rubleMin))
        
        let rubleSize = CGSize(width: 64, height: 64)
        let safeRoadWidth = roadWidth - rubleSize.width
        
        //get on-spawn position
        let rublePosition = CGPoint(x: CGFloat(arc4random_uniform(UInt32(safeRoadWidth))) - (safeRoadWidth / 2), y: screenHeight+rubleSize.height)
        
        //let rublePosition = CGPoint(x: 220, y: screenHeight+rubleSize.height)
        
        super.init(texture: roadTextureAtlas.textureNamed("rubleTexture"), size: rubleSize, position: rublePosition, isPoint: true, isHatch: false, wheelsOnly: false, isInteractable: true)
    }
    
}


/*
 
 Class stores hole objects, with its unique properties
 Child class from generic road entity class
 
*/

class holeEntity : roadEntity
{
    //DATA
    
    // some data about damage
    
    //METHODS
    
    init(screenHeight : CGFloat, roadWidth : CGFloat)
    {
        let holeTexture = roadTextureAtlas.textureNamed("holeTexture_"+String(arc4random_uniform(2)))
        //... holeTextures[Int(arc4random_uniform(2))]
        
        let holeRotation = ((CGFloat(arc4random_uniform(180)) / 10) * CGFloat(CGFloat.pi / 180)) //random rotation from 0 to 18 degrees
        
        let holeSize = CGSize(width: 128, height: 128)
        let safeRoadWidth = roadWidth - holeSize.width
        
        //get on-spawn position
        let holePosition = CGPoint(x: CGFloat(arc4random_uniform(UInt32(safeRoadWidth))) - (safeRoadWidth / 2), y: screenHeight+holeSize.height)
        
        //let rublePosition = CGPoint(x: 220, y: screenHeight+rubleSize.height)
        
        super.init(texture: holeTexture, size: holeSize, position: holePosition, isPoint: false, isHatch: false, wheelsOnly: true, isInteractable: true)
        
        super.getSpriteNode().zRotation = holeRotation
    }
}


/*
 
 Class stores hatch objects, with its unique properties
 Child class from generic road entity class
 
*/

class hatchEntity : roadEntity
{
    //DATA
    
    var hatchType : Int
    let damagedHatchWillBreak : Bool 
    
    //METHODS
    
    init(screenHeight : CGFloat, roadWidth : CGFloat)
    {
        //hatchTextures[0].filteringMode = .linear
        let chance = arc4random_uniform(3);
        if (chance == 1) { damagedHatchWillBreak = true } else { damagedHatchWillBreak = false }
        
        //hatch type -> 0 = closed; 1 = open; 2 = damaged
        let hatchType = Int(arc4random_uniform(2) + 1) //OPEN OR DAMAGED ONLY
        self.hatchType = hatchType
        var interact : Bool
        if hatchType > 0 { interact = true } else { interact = false }
        let hatchTexture = roadTextureAtlas.textureNamed("hatchTexture_"+String(hatchType))
        //hatchTextures[hatchType]
        
        var hatchSize = CGSize(width: 128, height: 128)
        let hatchRoadWidth = roadWidth - (hatchSize.width*2) //чтобы люк в прям полосу))
        
        if(hatchType == 0 || hatchType == 2)
        {
            hatchSize.width *= 0.8
            hatchSize.height *= 0.8
        }
        
        //get on-spawn position
        let hatchPosition = CGPoint(x: CGFloat(arc4random_uniform(UInt32(hatchRoadWidth))) - (hatchRoadWidth / 2), y: screenHeight+hatchSize.height)
        
        //let rublePosition = CGPoint(x: 220, y: screenHeight+rubleSize.height)
        
        super.init(texture: hatchTexture, size: hatchSize, position: hatchPosition, isPoint: false, isHatch: true, wheelsOnly: true, isInteractable: interact)
    }
}


/*
 
 Class stores plank objects, with its unique properties
 Child class from generic road entity class
 
 */

class plankEntity : roadEntity
{
    //DATA
    
    let plankRotation : CGFloat //plank rotation in radians
    
    //METHODS
    
    init(screenHeight : CGFloat, roadWidth : CGFloat)
    {
        self.plankRotation = (CGFloat(arc4random_uniform(180)) * CGFloat(CGFloat.pi / 180))
        let interact : Bool = true
        
        let plankSize = CGSize(width: 128, height: 19.52)
        let safeRoadWidth = roadWidth - (plankSize.width * 2)
        
        //get on-spawn position
        let plankPosition = CGPoint(x: CGFloat(arc4random_uniform(UInt32(safeRoadWidth))) - (safeRoadWidth / 2), y: screenHeight+plankSize.width)
        
        
        super.init(texture: roadTextureAtlas.textureNamed("plankTexture"), size: plankSize, position: plankPosition, isPoint: false, isHatch: false, wheelsOnly: true, isInteractable: interact)
        
        super.getSpriteNode().zRotation = plankRotation
        super.isPlank = true
    }
}



/*
 
 Class stores speedbump objects, with its unique properties
 Child class from generic road entity class
 
*/

class speedbumpEntity : roadEntity
{
    //DATA
    weak var gameScene : GameScene?
    
    var hitboxCircles : [SKShapeNode] = []
    
    //active sections
    let sbTypes = [ [0,1,2], [0,3,4], [0,1,4] ]
    
    //METHODS
    init(screenHeight : CGFloat, roadWidth : CGFloat, scene: GameScene)
    {
        gameScene = scene;
        
        let speedbumpSize = CGSize(width: roadWidth*0.9, height: 48)
        
        //type&texture
        let index = Int(arc4random_uniform(3))
        let speedbumpTexture = roadTextureAtlas.textureNamed("speedbump_"+String(index))
        //speedbumps[index]
        let speedbumpType = sbTypes[index]
        
        //get on-spawn position (±150m)
        let speedbumpPosition = CGPoint(x: 0, y: screenHeight+(4500))
        
        //set hitboxes
        
        var xPos = -1 * (roadWidth*0.9)/2;
        
        for i in 0...4
        {
            if (speedbumpType.firstIndex(of: i) != nil)
            {
                let hbox = SKShapeNode(circleOfRadius: 32) // Size of Circle
                hbox.strokeColor = SKColor.init(red: 1, green: 0, blue: 0, alpha: 0)
                hbox.glowWidth = 1.0
                hbox.fillColor = SKColor.clear
                hbox.zPosition = 20
                hbox.position = CGPoint(x: xPos, y: speedbumpPosition.y)
               
                hitboxCircles.append(hbox)
                gameScene!.addChild(hbox)
            }
            
            xPos += (roadWidth*0.9)/4
        }
        
        super.init(texture: speedbumpTexture, size: speedbumpSize, position: speedbumpPosition, isPoint: false, isHatch: false, wheelsOnly: true, isInteractable: true)
        
        super.isSpeedbump = true;
    }
    
    deinit
    {
        //print("speedbump deinit called!")
        
        for hitbox in hitboxCircles
        {
            hitbox.removeFromParent()
        }
        
        hitboxCircles.removeAll()
    }
    
    /*
     
     Intersecting test
     Arguments : center point of each wheel
     
     Overrides base class method!!
     
     */
    
    public override func collides(Car : CGPoint, LF : CGPoint, RF : CGPoint, LR : CGPoint, RR : CGPoint) -> Bool
    {
        if(!isInteractable) { return false; }
        
        //move
        for hitbox in hitboxCircles
        {
            hitbox.position.y = damageDebugCircle.position.y; //super.damageDebugCircle.position.y
        }
        
        //detect intersections w/ wheels
        for hitbox in hitboxCircles
        {
            guard let imp = gameScene?.carObject?.intersects(hitbox) else { continue; }
            if (imp) {
                isInteractable = false;
                sharedMethodsStorage.makeBzzzzByVibrator();
                return true;
            }
        }
        
        return false
    }
}


/*

 This class presents an object with label and texture to display record on road
 
*/

class highScoreVisualEntity
{
    //DATA
    
    var textLabel : SKLabelNode
    var gradientSprite : SKSpriteNode
    
    //METHODS
    
    init(screenHeight : CGFloat, screenWidth : CGFloat, highScore : String)
    {
        textLabel = SKLabelNode(text: " "+highScore)
        textLabel.zPosition = 22
        textLabel.alpha = 1
        textLabel.fontSize = 42
        textLabel.fontName = "Marker Felt Wide"
        
        textLabel.fontColor = UIColor(displayP3Red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        
        gradientSprite = SKSpriteNode(texture: roadTextureAtlas.textureNamed("gradientTexture"), size: CGSize(width: 256, height: 64))
        
        gradientSprite.anchorPoint = CGPoint(x: 0, y: 0)
        textLabel.horizontalAlignmentMode = .left
        textLabel.position = CGPoint(x: -screenWidth + 15, y: screenHeight + 17)
        gradientSprite.position = CGPoint(x: -screenWidth, y: screenHeight + 1)
        gradientSprite.zPosition = 21
        gradientSprite.alpha = 0.5
        
        //print("added " + highScore)
    }
    
    
    /*
     
     Slides down object
     
    */
    
    public func tickDown(velocity : CGFloat)
    {
        gradientSprite.position.y -= velocity
        textLabel.position.y -= velocity
    }
    
    
    /*
     
     Screen bounds check
     
    */
    
    public func isInScreenBounds(bounds : CGFloat) -> Bool
    {
        let currentY = gradientSprite.position.y
        if(currentY < ((-1*bounds)-48))
        {
            return false
        }
        
        return true
    }
}



/*

 Class stores a Power-Ups object
 
*/

class powerUpsEntity : roadEntity
{
    //DATA
    
    //power-ups types:
    //0 - superspeeeed
    //1 - godmode
    //2 - repair
    
    var powerUpsType : Int = 0; //value
    
    //METHODS
    
    init(screenHeight : CGFloat, roadWidth : CGFloat, hitsCounter : Int)
    {
        if(hitsCounter > 0) { powerUpsType = 2; }
        else { powerUpsType = Int(arc4random_uniform(2));  }
        
        var powerUpsSize = CGSize(width: 72, height: 72)
        if(powerUpsType == 0) { powerUpsSize = CGSize(width: 64, height: 85) } //kanistra
        if(powerUpsType == 1) { powerUpsSize = CGSize(width: 98, height: 64) } //furazhka
        let safeRoadWidth = roadWidth - powerUpsSize.width
        
        //get on-spawn position
        let powerUpsPosition = CGPoint(x: CGFloat(arc4random_uniform(UInt32(safeRoadWidth))) - (safeRoadWidth / 2), y: screenHeight+powerUpsSize.height)
        
        super.init(texture: roadTextureAtlas.textureNamed("powerups_"+String(powerUpsType)), size: powerUpsSize, position: powerUpsPosition, isPoint: false, isHatch: false, wheelsOnly: false, isInteractable: true)
        
        super.isPowerUps = true
    }
    
}


/*
 
 Class stores pipe objects, with its unique properties
 Child class from generic road entity class
 
 */

class pipeEntity : roadEntity
{
    //DATA
    
    var sprayEffect : SKEmitterNode
    
    //METHODS
    
    init(screenHeight : CGFloat, roadWidth : CGFloat)
    {
        let pipeTexture = roadTextureAtlas.textureNamed("pipeTexture")
        //... holeTextures[Int(arc4random_uniform(2))]
        
        let pipeSize = CGSize(width: 220, height: 190)
        let safeRoadWidth = roadWidth - pipeSize.width
        
        //get on-spawn position
        let pipePosition = CGPoint(x: CGFloat(arc4random_uniform(UInt32(safeRoadWidth))) - (safeRoadWidth / 2), y: screenHeight+pipeSize.height)
    
        //water particle
        var effectName = "waterSpray"
        
        if let sc = sharedDataStorage.gameSceneLink
        {
            if (sc.winterMode)
            {
                effectName = "waterSteam";
            }
        }
        
        let effectPath = Bundle.main.path(forResource: effectName, ofType: "sks")
        sprayEffect = NSKeyedUnarchiver.unarchiveObject(withFile: effectPath!) as! SKEmitterNode
        
        super.init(texture: pipeTexture, size: pipeSize, position: pipePosition, isPoint: false, isHatch: false, wheelsOnly: true, isInteractable: true)
       
        super.isPipe = true
        
        sprayEffect.position = pipePosition
        sprayEffect.position.x += 20
        sprayEffect.name = "pipeWaterSpray"
        //sprayEffect.zPosition = 6
        //sprayEffect.speed = -14
        
    }
    
    
    /*
     
     Slides down object
     
    */
    
    public override func tickDown(velocity : CGFloat)
    {
        sprite.position.y -= velocity
        damageDebugCircle.position.y -= velocity
        sprayEffect.position.y -= velocity
    }
    
}
