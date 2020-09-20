//
//  GameScene.swift
//  Crazy Russian Road
//
//  Created by Muxa Mot on 05.09.2018.
//  Copyright © 2018 Muxa Mot. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
import Firebase

class GameScene: SKScene
{
    //DATA
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    
    //Game
    //Okay, I know that keeping all game vars in single class is spaghetti code
    //but I dont care =)
    public var points : Int = 0
    public var kilometers : CGFloat = 0
    public var hitCounter : Int = 0
    public var damagedWheel : Int = 0
    public var hasDamagedWheel : Bool = false
    public var gamePaused : Bool = false
    public var pauseScreenIsShownig : Bool = false
    public var whitescreenTimerIsActive : Bool = false
    public weak var vcReference : UIViewController?
    public var gameInTutorialMode : Bool = false
    public var fadeRectangle : SKShapeNode?
    private var revivePrice : Int = 10;
    public var repairPrice : Int = 30;
    private var repairScore : Int = 0;
    private var carRespawnNeeded : Bool = false;
    private let cars = carsStorage()
    public var nightMode : Bool = true;
    public var headlightOn : Bool = true;
    public var minimumRubleValue : UInt = 1;
    public var maximumRubleValue : UInt = 5;
    public var revivesCount : UInt = 0;
    private var magicSpeedMultiplier : CGFloat = 5.454; //7.272 for "start-on-60" mode
    
    //bonuses
    public var superspeedMode : Bool = false;
    public var superspeedModeTimer : Int = 1000;
    public var godmodeMode : Bool = false;
    public var godmodeTimer : Int = 1000;
    
    //Night mode
    public var nightMask : SKSpriteNode?
    public var nightMaskTexture : SKTexture?
    public var nightDark : SKTexture?
    public var isFaryEnabled : Bool = false
    
    //winter mode
    public var winterMode : Bool = false;
    
    //Car
    public var carObject : SKSpriteNode?
    public var carVelocity : CGFloat = 8.25
    public var speedLimit : CGFloat = 11.00
    private var destX : CGFloat = 0.0
    public var steeringAnimationsCounter : Int = 0
    public var hitAnimationPlaying : Bool = false
    private var speedLevel : Int = 1
    public var carSavedRotation : CGFloat = 0
    public var leftFara : SKSpriteNode?
    public var rightFara : SKSpriteNode?
    
    //Car wheels
    private var LeftFront_Wheel : SKSpriteNode?
    private var RightFront_Wheel : SKSpriteNode?
    private var LeftRear_Wheel : SKSpriteNode?
    private var RightRear_Wheel : SKSpriteNode?
    
    //Car particle systems
    public var preloadSequenceActive : Bool = false
    public var sparkParticle : SKEmitterNode?
    public var smokeParticle : SKEmitterNode?
    public var impactParticle : SKEmitterNode?
    public var impactSmokesParticle : SKEmitterNode?
    public var totaledParticle : SKEmitterNode?
    public var snowParticle : SKEmitterNode?
    public var snowParticleActive : Bool = false
    
    //viewport size
    public var sceneSizeWidth : CGFloat = 0
    public var sceneSizeHeight : CGFloat = 0
    public let ipadUpscaleRate : CGFloat = 1.302734375;
    public let iphoneXUpscaleRate : CGFloat = 1.21875;
    public var iphoneXAdaptationNeeded : Bool = false;
    
    //Road
    public var roadObject : SKSpriteNode?
    public var roadShoulders : SKSpriteNode?
    public var roadLineLeft : SKSpriteNode?
    public var roadLineRight : SKSpriteNode?
    public var roadBackground : SKSpriteNode?
    
    //HUD & ingame notific.
    private var hudPointsCounterLabel : SKLabelNode?
    private var hudSpeedometerLabel : SKLabelNode?
    private var hudOdometerLabel : SKLabelNode?
    private var hudPointsCounterLabelBg : SKSpriteNode?
    private var hudSpeedometerLabelBg : SKSpriteNode?
    private var hudOdometerLabelBg : SKSpriteNode?
    private var hudRubleLogo : SKSpriteNode?
    public var pauseButton : SKSpriteNode?
    private var notificationsBg : SKSpriteNode?
    private var repairNotify : SKSpriteNode?
    private var repairNotifyString : SKLabelNode?
    private var stringNotify : SKLabelNode?
    public var notifyController : ingameNotifications?
    public var hudBonusProgressBarBackground : SKShapeNode?
    public var hudBonusProgressBar : SKShapeNode?
    public var hudBonusProgressBarIndicator : SKSpriteNode?
    
    //Road markup
    private var markingLines = [SKSpriteNode?]()
    private var markupLineSize = CGSize()
    
    //roadside entities
    public var streetLights : streetLight?
    public var foliage : foliages?
    public var snowbank : snowBanks?
    
    //Road entities
    private var roadEntities = [roadEntity]()
    private var entitySpawnerTimeout : Int = 0
    private var speedbumpSpawnerTimeout : Int = 0
    private var powerupsSpawnerTimeout : Int = 1984
    
    //touch controls
    public var haveTouch = false
    public var touchObject : UITouch? = nil
    
    //high scores
    public var highScoresManager : highScores = highScores()
    public var highScoreVisuals = [highScoreVisualEntity]()
    public var highScoresVisualsTimeout = 0
    public var highScoresGameType = 0
    
    //sound
    public var backgroundMusic : SKAudioNode!
    public var trackVolumeLevel : Float = 0.16
    
    //METHODS
    
    override func sceneDidLoad()
    {
        self.lastUpdateTime = 0
        
        //Bind car sprite from scene to this gameScene class
        self.carObject = self.childNode(withName: "//Car") as? SKSpriteNode
        // null pointer check (?) ....
        if let carObject = self.carObject
        {
            carObject.alpha = 1
            //carObject.run(SKAction.fadeIn(withDuration: 1))
            
            let currentCar = cars.getCarById(sVarsShared.currentCarId!)
            
            carObject.texture = SKTexture(image: currentCar!.carTexture)
            
            //if zapor make car shorter!
            if currentCar?.group == 4 { carObject.size.height = carObject.size.height * 0.9; }
            //devyatka
            if currentCar?.group == 2 {
                carObject.size.height = carObject.size.height * 0.95;
                isFaryEnabled = true
            }
        }
        
        //creates streetlight objects
        self.streetLights = streetLight(scene : self)
        
        //creates foliage objects
        self.foliage = foliages(scene: self)
        
        //Bind wheels
        self.LeftFront_Wheel = self.childNode(withName: "//LF_Wheel") as? SKSpriteNode
        self.RightFront_Wheel = self.childNode(withName: "//RF_Wheel") as? SKSpriteNode
        self.LeftRear_Wheel = self.childNode(withName: "//LR_Wheel") as? SKSpriteNode
        self.RightRear_Wheel = self.childNode(withName: "//RR_Wheel") as? SKSpriteNode
        
        //faryyy lol
        self.leftFara = self.childNode(withName: "//leftFara") as? SKSpriteNode
        self.rightFara = self.childNode(withName: "//rightFara") as? SKSpriteNode
        
        //Sets markup line size
        markupLineSize.height = 200
        markupLineSize.width = 10
        
        //iphonex screen size detection
        let heightRatio = (UIScreen.main.bounds.height / UIScreen.main.bounds.width) * 9;
        if(heightRatio > 19.2) { iphoneXAdaptationNeeded = true; }
        
        //Bind road
        self.roadObject = self.childNode(withName: "//Road") as? SKSpriteNode
        self.roadShoulders = self.childNode(withName: "//shoulders") as? SKSpriteNode
        self.roadLineLeft =  self.childNode(withName: "//left_markup") as? SKSpriteNode
        self.roadLineRight =  self.childNode(withName: "//right_markup") as? SKSpriteNode
        self.roadBackground = self.childNode(withName: "//background") as? SKSpriteNode
        
        //expand road for iphoneX-like devices
        if(iphoneXAdaptationNeeded)
        {
            self.roadObject!.size.height *= iphoneXUpscaleRate
            self.roadShoulders!.size.height *= iphoneXUpscaleRate
            self.roadLineLeft!.size.height *= iphoneXUpscaleRate
            self.roadLineRight!.size.height *= iphoneXUpscaleRate
        }
        
        //Bind HUD points counter and speedometer
        self.hudPointsCounterLabel = self.childNode(withName: "//pointsCounter") as? SKLabelNode
        self.hudSpeedometerLabel = self.childNode(withName: "//speedometer") as? SKLabelNode
        self.hudOdometerLabel = self.childNode(withName: "//odometer") as? SKLabelNode
        self.pauseButton = self.childNode(withName: "//pauseButton") as? SKSpriteNode
        self.hudPointsCounterLabelBg = self.childNode(withName: "//pointsCounterBckg") as? SKSpriteNode
        self.hudSpeedometerLabelBg = self.childNode(withName: "//speedometerBckg") as? SKSpriteNode
        self.hudOdometerLabelBg = self.childNode(withName: "//odometerBckg") as? SKSpriteNode
        self.hudRubleLogo = self.childNode(withName: "//pointsLogo") as? SKSpriteNode
        
        //HUD iphoneX adoptation
        if(iphoneXAdaptationNeeded)
        {
            pauseButton?.position.y += 90;
            hudOdometerLabel?.position.y += 90;
            hudOdometerLabelBg!.position.y += 90;
            hudPointsCounterLabel?.position.y -= 95;
            hudPointsCounterLabelBg!.position.y -= 95;
            hudSpeedometerLabel?.position.y -= 95;
            hudSpeedometerLabelBg?.position.y -= 95;
            hudRubleLogo!.position.y -= 95;
        }
        
        self.notificationsBg = self.childNode(withName: "//notificationBackground") as? SKSpriteNode
        self.repairNotify = self.childNode(withName: "//damageNotification") as? SKSpriteNode
        self.repairNotifyString = self.childNode(withName: "//repairNotificationLabel") as? SKLabelNode
        self.stringNotify = self.childNode(withName: "//notificationLabel") as? SKLabelNode
        
        //notificationsBg?.size.width *= ipadUpscaleRate;
        self.notifyController = ingameNotifications(
            notificationsBackgound: self.notificationsBg!,
            repairSignLogo: self.childNode(withName: "//repairNotification") as! SKSpriteNode,
            repairSprite: self.repairNotify!,
            repairSpriteText: self.repairNotifyString!,
            textLabel: self.stringNotify!)
        
        //get screen size
        sceneSizeWidth = self.size.width
        sceneSizeHeight = self.size.height
        
        //SURVIVE ON RUSSIAN ROAD
        notificationsBg?.size.width = 0;
        if(sVarsShared.firstStartup! == false)
        {
            self.notifyController?.showString(message: NSLocalizedString("SURVIVE", comment: ""))
        }
        
        //INTRO FADE
        let introfadeRectangle = SKShapeNode(rectOf: CGSize(width: self.size.width * ipadUpscaleRate, height: self.size.height * iphoneXUpscaleRate))
        introfadeRectangle.alpha = 1
        introfadeRectangle.fillColor = .black
        introfadeRectangle.zPosition = 35
        self.addChild(introfadeRectangle)
        
        introfadeRectangle.run(SKAction.fadeOut(withDuration: 0.5), completion: {
            introfadeRectangle.removeFromParent()
        })
    }
   
    
    /*
     
     Called immediateley after a scene is presented by a view
     
    */
    
    override func didMove(to view: SKView)
    {
        //some analytics
        Analytics.logEvent("game_session_start", parameters: [:])
        
        //set static instance pointer
        sharedDataStorage.gameSceneLink = self
        
        //set shaders for night mode
        if nightMode
        {
            print("Nightmode mask load");
            initNightmode();
            carObject?.color = .black
            carObject?.colorBlendFactor = 0.75;
        }
        
        //Preload texture atlases
        roadTextureAtlas.preload {
            print("Textures loaded")
        }
        
        //set scene params for winter mode
        if winterMode
        {
            print("winter mode")
            initWinterMode()
            snowbank = snowBanks(scene : self)
        }
        
        highScoresGameType = 0
        if (winterMode) { highScoresGameType = 1 }
        if (nightMode) { highScoresGameType = 2 }
        
        //add camera
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: 0, y: 0);
        scene!.addChild(cameraNode)
        scene!.camera = cameraNode
        
        //set basic scale very low
        scene?.camera?.setScale(0.85);
        
        // Gracefully update camera scale for device / orientation
        let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        camera!.updateScaleFor(userInterfaceIdiom: userInterfaceIdiom, ipadRatio: ipadUpscaleRate, iphoneXRatio: iphoneXUpscaleRate)
        
        //add swipe right support
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedRight))
        
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        //add swipe left support
        let swipeLeft : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedLeft))
        
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        //get screen size
        sceneSizeWidth = self.size.width
        sceneSizeHeight = self.size.height
        
        //creates progress bar
        initProgressBar()
        
        //crates particle systems
        initializeParticleSystems()
        
        showTutorialIfNeeded() // shows tutorial
        
        //plays background music
        var trackName = "track4"; trackVolumeLevel = 0.3;
        if(nightMode) { trackName = "track2"; trackVolumeLevel = 0.16; }
        if(winterMode) { trackName = "track5_a"; trackVolumeLevel = 0.3; }
        if let musicURL = Bundle.main.url(forResource: trackName, withExtension: "mp3")
        {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
            backgroundMusic.run(SKAction.changeVolume(to: Float(trackVolumeLevel), duration: 0.1))
        }
    
        //ads update!
        //start downloading ad in background
        DispatchQueue.main.async {
            sharedAdsManager.createAndLoadIntersitialAd()
        }
        
    }
    
        
    /*
    
     Steers with touches
     
    */
    
    func subSteer()
    {
        if(hitCounter >= 3) { return } //car doesnt steers when crashed
        if(hitAnimationPlaying) { return } //car doesent steers when shaking
        if haveTouch && touchObject != nil && steeringAnimationsCounter == 0
        {
            //print(touchObject?.location(in: self))
            if touchObject!.location(in: self).x > CGFloat(0.0) //Right half of screen
            {
                carObject?.position.x += 1.2
                if(steeringAnimationsCounter == 0)
                {
                    self.carObject?.run(SKAction.rotate(toAngle: -1*(5 * (CGFloat.pi/180)), duration: 0.25))
                }
            }
            else    //left screen half
            {
                carObject?.position.x -= 1.2
                if(steeringAnimationsCounter == 0)
                {
                    self.carObject?.run(SKAction.rotate(toAngle: (5 * (CGFloat.pi/180)), duration: 0.25))
                }
            }
        }
    }
    
    
    /*
    
     Called when user swipes right
     
    */
    
    @objc func swipedRight()
    {
        haveTouch = false
        if(hitCounter >= 3) { return }
        if(hitAnimationPlaying) { return }
        
        guard let currentX = self.carObject?.position.x else { return }
        self.destX = currentX + 120
        
        if winterMode
        {
            let randomOffset = Int(arc4random_uniform(180)) - 90
            self.destX += CGFloat(randomOffset)
        }
        
        //move car
        let movementAction = SKAction.moveTo(x: destX, duration: 0.5)
        self.carObject?.run(movementAction)
        
        self.steeringAnimationsCounter += 1;
        
        //do steering animation
        guard let steeringAction = SKAction(named: "steeringRight") else { return }
        self.carObject?.run(steeringAction, completion: {
            
            self.steeringAnimationsCounter -= 1;
            
            self.shiftCar()
        })
        
        //do steering animation on front wheels lol
        guard let steeringAction2 = SKAction(named: "steeringRight1") else { return }
        self.LeftFront_Wheel?.run(steeringAction2)
        self.RightFront_Wheel?.run(steeringAction2)
    }

    
    /*
     
     Called when user swipes left
     
    */
    
    
    @objc func swipedLeft()
    {
        haveTouch = false
        if(hitCounter >= 3) { return } //car doesnt steers
        if(hitAnimationPlaying) { return } //car doesent steers when shaking
        
        guard let currentX = self.carObject?.position.x else { return }
        self.destX = currentX - 120
        
        if winterMode
        {
            let randomOffset = Int(arc4random_uniform(180)) - 90
            self.destX += CGFloat(randomOffset)
        }
        
        //move car
        let movementAction = SKAction.moveTo(x: destX, duration: 0.5)
        self.carObject?.run(movementAction)
        
        self.steeringAnimationsCounter += 1;
        
        //do steering animation
        guard let steeringAction = SKAction(named: "steeringLeft") else { return }
        self.carObject?.run(steeringAction, completion: {
            
            self.steeringAnimationsCounter -= 1;
            
            self.shiftCar()
            
        })
        
        //do steering animation on wheels lol
        guard let steeringAction2 = SKAction(named: "steeringLeft1") else { return }
        self.LeftFront_Wheel?.run(steeringAction2)
        self.RightFront_Wheel?.run(steeringAction2)
    }
        
    
    /*
    
     Update road marking
     TODO - move to separate class for different behavior on different maps
     
    */
    
    func updateRoadMarking()
    {
        var viewportSize = sceneSizeHeight / 2 //view?.bounds.height else { return; }
        var lineNodesGeneratorPosition = viewportSize + markupLineSize.height
        
        if(iphoneXAdaptationNeeded) { viewportSize *= iphoneXUpscaleRate }
        
        //line array is empty, generate and fill it with lines
        if markingLines.count == 0
        {
            while (lineNodesGeneratorPosition > -viewportSize)
            {
                let newNode = SKSpriteNode(color: .white, size: markupLineSize)
                newNode.position.y = lineNodesGeneratorPosition
                newNode.blendMode = .replace
                newNode.zPosition = 3
                markingLines.append(newNode)
                self.addChild(newNode)
                
                lineNodesGeneratorPosition -= (markupLineSize.height * 2)
            }
            
            return
        }
        
        //remove line that goes off the screen
        for line in markingLines
        {
            guard let currentLineY = line?.position.y else { continue; }
            if(currentLineY < ((-1*viewportSize)-markupLineSize.height))
            {
                //line?.position.y = viewportSize + markupLineSize.height
                line?.removeFromParent()
                
                if let index = markingLines.index(of: line)
                {
                    markingLines.remove(at: index)
                }
            }
        }
        
        //move all lines down on screen, subtract car velocity from them
        for line in markingLines
        {
            guard let currentLineY = line?.position.y else { continue; }
            line?.position.y = currentLineY - carVelocity
        }
        
        //insert new lines in array
        guard let upperLinePosition = markingLines[0]?.position.y else { return }
        if(upperLinePosition < viewportSize)
        {
            let newNode = SKSpriteNode(color: .white, size: markupLineSize)
            newNode.position.y = viewportSize + (markupLineSize.height*2)
            newNode.blendMode = .replace
            newNode.zPosition = 3
            markingLines.insert(newNode, at: 0)
            self.addChild(newNode)
        }
    }
    
    
    /*
     
     Updates roadside entities
     
    */
    
    func updatesRoadsideEntities()
    {
        var impactSL : Bool? = false
        var impactFol : Bool? = false
        var ditch : Bool = false

        impactSL = streetLights?.updateHitboxesAndCheckForImpacts(velocity: carVelocity)
        impactFol = foliage?.updateHitboxesAndCheckForImpacts(velocity: carVelocity)
        streetLights?.tick(velocity: carVelocity)
        foliage?.tick(velocity: carVelocity)
        
        //snowbanks in winter mode
        if winterMode { snowbank?.tick(velocity: carVelocity) }
        
        //check car is on screen
        let viewportSizeX = sceneSizeWidth / 2;
        if ((carObject!.position.x < (-viewportSizeX - 32)) || (carObject!.position.x > (viewportSizeX + 32)))
        {
            ditch = true
        }
        
        if ((impactSL! || impactFol! || ditch) && hitCounter != 3) //(
        {
            hitCounter = 3;
            let backupImpactBirthRate = self.impactParticle?.particleBirthRate;
            
            //impact effects
            if(!ditch)
            {
                carVelocity = 0;
                headlightOn = false;
                
                self.addChild(impactParticle!)
                impactParticle?.position = carObject!.position
                if impactSL! { impactParticle?.position = streetLights!.lastHitPosition! }
                if impactFol! { impactParticle?.position = foliage!.lastHitPosition! }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400) )
                {
                    self.impactParticle?.particleBirthRate = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800) )
                {
                    self.impactParticle?.removeFromParent()
                }
                
                sharedMethodsStorage.makeBzzzzByVibrator()
                self.addChild(impactSmokesParticle!)
                
                impactSmokesParticle?.position = CGPoint(x: impactParticle!.position.x, y: impactParticle!.position.y)
                impactSmokesParticle?.resetSimulation()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000) )
                {
                    self.impactSmokesParticle?.removeFromParent()
                }
                
                playHitAnimation()
            }
            else
            {
                let driftAction = SKAction(named: "drift")
                carObject?.run(driftAction!)
                sharedMethodsStorage.makeBzzzzByVibrator()
            }
            
            //deletes smoke effects
            if hasDamagedWheel != false
            {
                smokeParticle?.removeFromParent()
                sparkParticle?.removeFromParent()
                hasDamagedWheel = false
            }
            
            //stop the music
            backgroundMusic.run(SKAction.changeVolume(to: Float(0), duration: 2))
            
            //lets do some fade!
            fadeRectangle = SKShapeNode(rectOf: CGSize(width: self.size.width * ipadUpscaleRate, height: self.size.height * iphoneXUpscaleRate))
            fadeRectangle!.alpha = 0
            fadeRectangle!.fillColor = .white
            fadeRectangle!.zPosition = 35
            self.addChild(fadeRectangle!)
            
            whitescreenTimerIsActive = true
            fadeRectangle!.run(SKAction.fadeIn(withDuration: 2.4),
                               completion: {
                                
                                //some bad sh.. swift magic =(
                                self.scene?.isPaused = true
                                self.gamePaused = true
                                self.carRespawnNeeded = true
                                self.impactParticle?.particleBirthRate = backupImpactBirthRate!;
                             
                                let storyboard0: UIStoryboard = UIStoryboard(name: "menu", bundle: nil)
                                let vc0 = storyboard0.instantiateViewController(withIdentifier: "defeatScreen") as! defeatScreenViewController
                                
                                vc0.gameVCReference = self.vcReference
                                
                                if (self.points >= self.revivePrice)
                                {
                                    vc0.isRevivable = true
                                }
                                else
                                {
                                    vc0.isRevivable = false
                                }
                                
                                vc0.revivePrice = self.revivePrice
                                vc0.isStreetlight = impactSL!
                                
                                self.vcReference?.present(vc0, animated: false, completion: nil)
                                self.whitescreenTimerIsActive = false
            })
        }
        
    }
    
    
    /*
    
     Updates HUD
     
    */
    
    func updateHUDLabels()
    {
        hudPointsCounterLabel?.text = String(self.points)
        //ok, magicSpeedMultiplier - is a magic number, that transforms our magic speed into a readable km/h
        hudSpeedometerLabel?.text
            = String(format: "%.0f", abs(Double(carVelocity * magicSpeedMultiplier))) + " Km/h"
        
        hudUpdateOdometer(odo: hudOdometerLabel!, km: kilometers)
        
    }
    
    
    /*
    
     Provides road entities
     
    */
    
    func updateRoadEntities()
    {
        //spawn new entities with some chance
        var viewportSize = sceneSizeHeight / 2 //= view?.bounds.height else { return; }
        guard let roadw = roadObject?.size.width else { return; }
        if(iphoneXAdaptationNeeded) { viewportSize *= iphoneXUpscaleRate }
        if(speedbumpSpawnerTimeout > 0) { speedbumpSpawnerTimeout -= 1; }
        
        var spawnerAllowed : Bool = false
        if(!roadEntities.isEmpty)
        {
            guard let lastPosY = roadEntities.last?.getSpriteNode().position.y else { return }
            let spawnerDistance : CGFloat = 50.0
            if(lastPosY < spawnerDistance)
            {
                spawnerAllowed = true
            }
        }
        else
        {
            spawnerAllowed = true
        }
        
        //Spawn new road entity object
        if(spawnerAllowed && fabs(carVelocity - speedLimit) < 0.1)
        {
            //spawn road entities
            
            let spawnerChance = arc4random_uniform(5)
            
            //monetochka
            if(spawnerChance == 0)
            {
                let newRuble : rubleEntity = rubleEntity(screenHeight: viewportSize, roadWidth: roadw, rubleMin: minimumRubleValue, rubleMax: maximumRubleValue)
                
                roadEntities.append(newRuble)
                self.addChild(newRuble.getSpriteNode())
                //self.addChild(newRuble.getDebugCircle())
            }
            
            //hole
            if(spawnerChance == 1)
            {
                let newHole : holeEntity = holeEntity(screenHeight: viewportSize, roadWidth: roadw)
                
                roadEntities.append(newHole)
                self.addChild(newHole.getSpriteNode())
                //self.addChild(newHole.getDebugCircle())
            }
            
            //hatch
            if(spawnerChance == 2)
            {
                let newHatch : hatchEntity = hatchEntity(screenHeight: viewportSize, roadWidth: roadw)
                
                roadEntities.append(newHatch)
                self.addChild(newHatch.getSpriteNode())
                //self.addChild(newHatch.getDebugCircle())
            }
            
            //woodplank
            if(spawnerChance == 3)
            {
                let newPlank : plankEntity = plankEntity(screenHeight: viewportSize, roadWidth: roadw)
                
                roadEntities.append(newPlank)
                self.addChild(newPlank.getSpriteNode())
            }
            
            //pipe
            if(spawnerChance == 4)
            {
                let newPipe : pipeEntity = pipeEntity(screenHeight: viewportSize, roadWidth: roadw)
                
                roadEntities.append(newPipe)
                self.addChild(newPipe.getSpriteNode())
                self.addChild(newPipe.sprayEffect)
            }
        }
        
        //speedbump
        if(kilometers.truncatingRemainder(dividingBy: 1.5) < 0.001 && kilometers > 0.1 && speedbumpSpawnerTimeout == 0)
        {
            speedbumpSpawnerTimeout = 400;
            
            self.notifyController?.showStringAndSign(message: NSLocalizedString("SPEEDBUMP", comment: "Speedbump ahead"), sign: SKTexture(image: #imageLiteral(resourceName: "speedbump_Sign")))
            
            let newSpeedbump : speedbumpEntity = speedbumpEntity(screenHeight: viewportSize, roadWidth: roadw, scene: self)
            
            roadEntities.append(newSpeedbump)
            self.addChild(newSpeedbump.getSpriteNode())
        }
        
        //PowerUps
        if(powerupsSpawnerTimeout == 0)
        {
            //check nearest entities
            var powerupsSpawnerAllowed = false
            
            if(!roadEntities.isEmpty)
            {
                guard let lastPosY = roadEntities.last?.getSpriteNode().position.y else { return }
                if(lastPosY < 64.0)
                {
                    powerupsSpawnerAllowed = true
                }
            } else { powerupsSpawnerAllowed = true }
            
            //spawn power-up
            if(powerupsSpawnerAllowed && fabs(carVelocity - speedLimit) < 0.1)
            {
                let newPowerUps : powerUpsEntity = powerUpsEntity(screenHeight: viewportSize, roadWidth: roadw, hitsCounter: hitCounter)
                
                roadEntities.append(newPowerUps)
                self.addChild(newPowerUps.getSpriteNode())
                
                //re-enable timer
                powerupsSpawnerTimeout = 1800;
            }
        }
        else
        {
            powerupsSpawnerTimeout -= 1;
        }
        
        
        //move down
        for entity in roadEntities { entity.tickDown(velocity: carVelocity) }
        
        //destroy off-screens
        for entity in roadEntities
        {
            if !entity.isInScreenBounds(bounds: viewportSize)
            {
                if entity.isPipe
                {
                    let et = entity as! pipeEntity
                    et.sprayEffect.removeFromParent()
                }
                
                entity.getSpriteNode().removeFromParent()
                //entity.getDebugCircle().removeFromParent()
                
                
                if let index = roadEntities.index(where: { r in r.getSpriteNode() == entity.getSpriteNode() }) //tupoy swift, kak je ya ego nenaviju
                {
                    roadEntities.remove(at: index)
                }
            }
        }
    }
    
    
    /*
    
     Updates game physics logic
     
    */
    
    func updatePhysics()
    {
        //test physics
        for entity in roadEntities
        {
            //KOSTYLI DA VELOSIPEDY
            let LFX = carObject!.convert(LeftFront_Wheel!.position, to: self.scene!)
            let RFX = carObject!.convert(RightFront_Wheel!.position, to: self.scene!)
            let LRX = carObject!.convert(LeftRear_Wheel!.position, to: self.scene!)
            let RRX = carObject!.convert(RightRear_Wheel!.position, to: self.scene!)
            
            let hit = entity.collides(Car: carObject!.position, LF: LFX, RF: RFX, LR: LRX, RR: RRX)
            
            if(hit)
            {
                //if rouble - score up
                //scores animation
                if(entity.isPoint)
                {
                    let point = entity as! rubleEntity
                    
                    let lbl = SKLabelNode(text: "+"+String(point.pointsValue))
                    lbl.position = point.getSpriteNode().position
                    //lbl.position.y += 64
                    //lbl.position.x -= 16
                    lbl.zPosition = 24
                    lbl.fontSize = 54
                    lbl.fontName = "Marker Felt Wide"
                    self.addChild(lbl)
                    //guard
                    let hideAction = SKAction.move(to: hudPointsCounterLabel!.position, duration: 0.86)
                    // = SKAction(named: "hideLabel") else { return }
                    hideAction.timingMode = .easeOut
                    lbl.run(hideAction, completion:
                        { self.points += point.pointsValue; lbl.removeFromParent() })
                }
                else if(entity.isPowerUps)
                {
                    let powerUps = entity as! powerUpsEntity
                    
                    //do not pick powerups if there is active one
                    if(!superspeedMode && !godmodeMode)
                    {
                        if(powerUps.powerUpsType == 0)
                        {
                            notifyController?.showString(message: NSLocalizedString("SUPERSPEED", comment: "super speed"))
                            superspeedMode = true;
                            superspeedModeTimer = 300;
                            showProgressBarFor(bonus: "powerups_0")
                        }
                        
                        if(powerUps.powerUpsType == 1)
                        {
                            notifyController?.showString(message: NSLocalizedString("GODMODE", comment: "god mode"))
                            godmodeMode = true;
                            godmodeTimer = 1000;
                            showProgressBarFor(bonus: "powerups_1")
                        }
                    }
                    
                    if(powerUps.powerUpsType == 2)
                    {
                        if(hitCounter == 1 && hasDamagedWheel)
                        {
                            notifyController?.showString(message: NSLocalizedString("REPAIR_B", comment: "bonus repair"))
                            hitCounter = 0;
                            damagedWheel = 0;
                            hasDamagedWheel = false;
                            smokeParticle?.removeFromParent()
                            sparkParticle?.removeFromParent()
                            if(carObject!.zRotation < CGFloat(0.1) && carObject!.zRotation > CGFloat(-0.1))
                            {
                                self.carObject?.run(SKAction.rotate(toAngle: 0, duration: 0.25))
                            }
                        }
                    }
                }
                else if(entity.isHatch) //if hatch
                {
                    let hatch = entity as! hatchEntity
                    
                    //if hatch is damaged, give damage with some chance
                    if(hatch.hatchType == 2)
                    {
                        if(hatch.damagedHatchWillBreak)
                        {
                            if(!superspeedMode && !godmodeMode)
                            {
                                hitCounter += 1
                                damagedWheel = hatch.hitByWheel
                            }
                            
                            //drift animation
                            playHitAnimation()
                        }
                    }
                    
                    //if hatch is opened, car is damaged anyway
                    if(hatch.hatchType == 1)
                    {
                        if(!superspeedMode && !godmodeMode)
                        {
                            hitCounter += 1
                            damagedWheel = hatch.hitByWheel
                        }
                        
                        //drift animation
                        playHitAnimation()
                    }
                    
                }
                else //all other - car gets damaged
                {
                    if(!superspeedMode && !godmodeMode)
                    {
                        if(!entity.isPlank) //except for planks
                        {
                            hitCounter += 1
                            damagedWheel = entity.hitByWheel
                        }
                        
                        //speedbump makes oneshot
                        if(entity.isSpeedbump && hitCounter < 2)
                        {
                            hitCounter = 2;
                        }
                    }
                    
                    if(entity.isPlank)
                    {
                        let randOffset = CGFloat(Int(arc4random_uniform(400)) - 200)
                        carObject?.run(SKAction.moveBy(x: randOffset, y: 0, duration: 0.8))
                    }
                    
                    //drift animation
                    playHitAnimation()
                }
            }
        }
    }
    
    
    /*
     
     Updates car destruction model
     
    */

    func updateCarDamage()
    {
        if(hitCounter == 1)
        {
            //initially
            //play car crash animations here
            if(damagedWheel != 0 && hasDamagedWheel == false)
            {
                hasDamagedWheel = true
                carVelocity = 5.5
                self.addChild(smokeParticle!)
                self.addChild(sparkParticle!)
                repairScore = points + repairPrice
                notifyController?.showRepairSign(scoreNeeded: repairPrice)
            }
            
            //drifting in left or right side, depends on damaged wheel
            if(hasDamagedWheel)
            {
                if(damagedWheel == 1 || damagedWheel == 3)
                {
                    carObject?.position.x -= 0.35
                    if(fabs(Double(carObject!.zRotation)) < 0.05 && steeringAnimationsCounter == 0 && haveTouch == false)
                    {
                        //carObject?.zRotation += (5 * (CGFloat.pi/180))
                        self.carObject?.run(SKAction.rotate(toAngle: (5 * (CGFloat.pi/180)), duration: 0.25))
                    }
                }
                if(damagedWheel == 2 || damagedWheel == 4)
                {
                    carObject?.position.x += 0.35
                    if(fabs(Double(carObject!.zRotation)) < 0.05 && steeringAnimationsCounter == 0 && haveTouch == false)
                    {
                        //carObject?.zRotation += -(5 * (CGFloat.pi/180))
                        self.carObject?.run(SKAction.rotate(toAngle: -1*(5 * (CGFloat.pi/180)), duration: 0.25))
                    }
                }
            }
            
        }
        
        if(hitCounter == 2)
        {
            hitCounter += 1 //lol
            
            //end up smokes
            smokeParticle?.removeFromParent()
            sparkParticle?.removeFromParent()
            
            //lets do some fade!
            fadeRectangle = SKShapeNode(rectOf: CGSize(width: self.size.width * ipadUpscaleRate, height: self.size.height * iphoneXUpscaleRate))
            fadeRectangle!.alpha = 0
            fadeRectangle!.fillColor = .white
            fadeRectangle!.zPosition = 35
            self.addChild(fadeRectangle!)
            
            //death animations
            
            let delayedFade = SKAction(named: "delayedFadeIn")
            let zoom = SKAction(named: "cameraZoomIn");
            let driftAngle = CGFloat(Double.random(in: -3.1415 ..< 3.1415))
            let deathDriftAction = SKAction.rotate(toAngle: driftAngle, duration: 1)
            
            self.camera?.run(zoom!)
            self.carObject?.run(deathDriftAction)
            self.addChild(totaledParticle!)
            totaledParticle?.position = carObject!.position
            self.totaledParticle?.resetSimulation()
            
            //stop music
            backgroundMusic.run(SKAction.changeVolume(to: Float(0), duration: 3))
            
            //fade
            whitescreenTimerIsActive = true
            fadeRectangle!.run(delayedFade!,
                              completion: {
                                
                                //reset camera
                                self.camera?.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0))
                                let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom
                                self.camera!.updateScaleFor(userInterfaceIdiom: userInterfaceIdiom, ipadRatio: self.ipadUpscaleRate, iphoneXRatio: self.iphoneXUpscaleRate)
                                
                                //reset smokes
                                self.totaledParticle?.resetSimulation()
                                self.totaledParticle?.removeFromParent()
                                
                                //some bad sh.. swift magic =(
                                self.scene?.isPaused = true
                                self.gamePaused = true
                                
                                let storyboard0: UIStoryboard = UIStoryboard(name: "menu", bundle: nil)
                                let vc0 = storyboard0.instantiateViewController(withIdentifier: "defeatScreen") as! defeatScreenViewController
                                
                                vc0.gameVCReference = self.vcReference
                                
                                if (self.points >= self.revivePrice)
                                {
                                    vc0.isRevivable = true
                                }
                                else
                                {
                                    vc0.isRevivable = false
                                }
                                
                                vc0.revivePrice = self.revivePrice
                                
                                self.vcReference?.present(vc0, animated: false, completion: nil)
                                
                                self.whitescreenTimerIsActive = false
            })
    
        }
        
        //some kostyls
        if(hitCounter > 3)
        {
            hitCounter = 3;
        }
        
        //stop car
        //car is totaled now, so do not accept any steering actions!
        if(hitCounter == 3)
        {
            if(carVelocity > 0.03)
            {
                carVelocity -= 0.04
            }
        }
        
        //updates damage effects position
        if(damagedWheel != 0 && hasDamagedWheel == true)
        {
            switch damagedWheel
            {
            case 1:
                sparkParticle!.position = carObject!.convert(LeftFront_Wheel!.position, to: self.scene!)
                smokeParticle!.position = carObject!.convert(LeftFront_Wheel!.position, to: self.scene!)
                break;
            case 2:
                sparkParticle!.position = carObject!.convert(RightFront_Wheel!.position, to: self.scene!)
                smokeParticle!.position = carObject!.convert(RightFront_Wheel!.position, to: self.scene!)
                break;
            case 3:
                sparkParticle!.position = carObject!.convert(LeftRear_Wheel!.position, to: self.scene!)
                smokeParticle!.position = carObject!.convert(LeftRear_Wheel!.position, to: self.scene!)
                break;
            case 4:
                sparkParticle!.position = carObject!.convert(RightRear_Wheel!.position, to: self.scene!)
                smokeParticle!.position = carObject!.convert(RightRear_Wheel!.position, to: self.scene!)
                break;
            default:
                sparkParticle!.position = carObject!.convert(LeftFront_Wheel!.position, to: self.scene!)
                smokeParticle!.position = carObject!.convert(LeftFront_Wheel!.position, to: self.scene!)
                break;
            }
        }
    }
    
    
    /*
    
    Restores scene after "Save Me" pressed
     
    */
    
    public func restoreAfterCarAccident()
    {
        revivesCount += 1;
        hitCounter = 0
        hasDamagedWheel = false
        damagedWheel = 0
        repairScore = 0
        carVelocity = 5.5
        headlightOn = true
        
        haveTouch = false
        touchObject = nil
        
        carObject?.zRotation = 0;
        
        if carRespawnNeeded || (abs(carObject!.position.x) > (roadObject!.size.width/2 - 32))
        {
            carObject!.position.x = 0;
            carRespawnNeeded = false
        }
        
        //destroy all current entities
        for entity in roadEntities
        {
            if entity.isPipe
            {
                let et = entity as! pipeEntity
                et.sprayEffect.removeFromParent()
            }
            
            entity.getSpriteNode().removeFromParent()
                
            if let index = roadEntities.index(where: { r in r.getSpriteNode() == entity.getSpriteNode() }) //tupoy swift, kak je ya ego nenaviju
            {
                roadEntities.remove(at: index)
            }
        }
        
        self.scene?.isPaused = false
        self.gamePaused = false
        
        //get song back
        backgroundMusic.run(SKAction.changeVolume(to: Float(trackVolumeLevel), duration: 4))
        
        //headlights
        if (isFaryEnabled && nightMode)
        {
            leftFara?.run(SKAction.fadeAlpha(to: 0.75, duration: 3))
            rightFara?.run(SKAction.fadeAlpha(to: 0.75, duration: 3))
        }
        
        godmodeMode = false; godmodeTimer = 2;
        superspeedMode = false; superspeedModeTimer = 2;
        hudBonusProgressBarBackground?.alpha = 0
        hudBonusProgressBar?.alpha = 0;
        hudBonusProgressBarIndicator?.alpha = 0
        
        //get light back
        if nightMode { nightMask?.texture = nightMaskTexture }
        
        fadeRectangle?.run(SKAction.fadeOut(withDuration: 1), completion: { self.fadeRectangle?.removeFromParent() })

        //points = points - revivePrice
        revivePrice = revivePrice * 10
        
        //self.notifyController?.showString(message: NSLocalizedString("PRICE", comment: "price x10"))
        
        //ads update!
        //start downloading ad in background
        DispatchQueue.main.async {
            if(sharedAdsManager.interstitialAd == nil || sharedAdsManager.interstitialAd.hasBeenUsed)
            {
                sharedAdsManager.createAndLoadIntersitialAd()
            }
        }

    }
    
    
    /*
    
     Score and bonus management
     
    */
    
    func checkScore()
    {
        let lastSpeedLevel = speedLevel;
        
        if(points >= 0){ speedLevel = 1; speedLimit = 11.00 } //60
        if(points >= 20){ speedLevel = 2; speedLimit = 14.66 } //80
        if(points >= 60){ speedLevel = 3; speedLimit = 18.33 } //100
        if(points >= 120){ speedLevel = 4; speedLimit = 22.00 } //120
        if(points >= 240){ speedLevel = 5; speedLimit = 25.66 } //140
        if(points >= 360){ speedLevel = 6; speedLimit = 29.33 } //160
        if(points >= 480){ speedLevel = 7; speedLimit = 33.00 } //180
        if(points >= 600){ speedLevel = 8; speedLimit = 36.67 } //200
        
        //speedlevel changed
        if (lastSpeedLevel < speedLevel)
        {
            self.notifyController?.showString(message: NSLocalizedString("ACCELERATED", comment: "accelerated"))
            Analytics.logEvent("level_up", parameters: ["level": speedLevel])
        }
        
        //bonuses
        updateBonuses()
        
        //repair
        if (hasDamagedWheel && hitCounter == 1)
        {
            if (points >= repairScore)
            {
                hitCounter = 0;
                damagedWheel = 0;
                hasDamagedWheel = false;
                smokeParticle?.removeFromParent()
                sparkParticle?.removeFromParent()
                if(carObject!.zRotation < CGFloat(0.1) && carObject!.zRotation > CGFloat(-0.1))
                {
                    self.carObject?.run(SKAction.rotate(toAngle: 0, duration: 0.25))
                }
                self.notifyController?.showString(message: NSLocalizedString("REPAIRED", comment: "repaired"))
            }
        }
        
        kilometers += (carVelocity * magicSpeedMultiplier) / (60 * 60 * 60)
    }
    
    
    /*
     
     Update game cycle.
     Called before each frame is rendered
     
    */
    
    override func update(_ currentTime: TimeInterval)
    {
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0)
        {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        //do not update anything if game is paused
        if (self.gamePaused == true)
        {
            return;
        }
        
        // Update entities
        for entity in self.entities
        {
            entity.update(deltaTime: dt)
        }
        
        //Updates screen size
        sceneSizeWidth = self.scene!.size.width
        sceneSizeHeight = self.scene!.size.height
        
        //Updates car velocity
        if(carVelocity < speedLimit && hitCounter != 3 && !gameInTutorialMode)
        {
            carVelocity += 0.01
        }
        
        if(carVelocity > (speedLimit+0.01) && hitCounter != 3)
        {
            carVelocity -= 0.01
        }
        
        //block car movement in tutorial mode
        if(gameInTutorialMode && carObject?.position.x != 0)
        {
            let moveAction = SKAction.moveTo(x: 0, duration: 0.1)
            carObject?.run(moveAction)
        }
        
        //some preload for particle systems (on init only)
        preloadParticlesIfNeeded()
        
        if winterMode && !preloadSequenceActive && !snowParticleActive
        {
            snowParticle?.advanceSimulationTime(10)
            self.addChild(snowParticle!)
            snowParticleActive = true;
        }
        
        //sound engine global on/off
        if !sVarsShared.soundEnabled
        {
            self.scene!.audioEngine.mainMixerNode.outputVolume = 0;
        }
        else
        {
            self.scene!.audioEngine.mainMixerNode.outputVolume = 1;
        }
        
        //score logic
        checkScore()
        
        //steering with touches
        subSteer();
        
        //Updates road markup
        updateRoadMarking()
        
        //Updates roadside obj
        updatesRoadsideEntities()
        
        //updates HUD
        updateHUDLabels()
        
        //updates road entities
        updateRoadEntities()
        
        //updates high scores visuals
        updateHighScoreVisuals()
        
        //updates hit data
        updatePhysics()
        
        //updates car damage model
        updateCarDamage()
        
        //updates shader data on GPU
        updateNightmode()
        
        self.lastUpdateTime = currentTime
    }
}
