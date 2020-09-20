//
//  gameMisc.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 09.02.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import Firebase


/*

 This is miscanellious extention for main GameScene class
 It contains helping functions, and useful stuff
 
*/

extension GameScene
{
    
    /*
    
     Проигрывает анимацию попадания столкновения
     Машину кидает в сторону, экран трясется
     
    */
    
    func playHitAnimation()
    {
        // disable hit animation when death whitescreen fadeIn animation playing
        if self.whitescreenTimerIsActive { return }
        
        self.hitAnimationPlaying = true
            
        self.steeringAnimationsCounter += 1;
        guard let hitAction = SKAction(named: "hit") else { return; }
        self.carObject!.run(hitAction, completion:
            {
                self.steeringAnimationsCounter -= 1;
                self.hitAnimationPlaying = false
            })
        
        //shakin teh camera!
        var hitZoomFactor : CGFloat = 0.9;
        var normalZoomFactor : CGFloat = 1.0;
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            normalZoomFactor = ipadUpscaleRate
            hitZoomFactor = ipadUpscaleRate * 0.9
        }
        
        if(iphoneXAdaptationNeeded)
        {
            normalZoomFactor = iphoneXUpscaleRate
            hitZoomFactor = iphoneXUpscaleRate * 0.9
        }
        
        guard let cameraShakingAction = SKAction(named: "cameraShake") else { return; }
        let zoomAction = SKAction.scale(to: hitZoomFactor, duration: 0.1)
        let unZoomAction = SKAction.scale(to: normalZoomFactor, duration: 0.1)
        self.camera!.run(zoomAction, completion:
        {
            self.camera!.run(cameraShakingAction, completion:
                {
                    self.camera!.run(unZoomAction)
                })
        })
    }
    
    
    /*
     
     car shifts when wheel damaged
     
     */
    
    func shiftCar()
    {
        if(self.steeringAnimationsCounter == 0 && hitCounter != 3)
        {
            if(self.damagedWheel == 1 || self.damagedWheel == 3)
            {
                self.carObject?.run(SKAction.rotate(toAngle: (5 * (CGFloat.pi/180)), duration: 0.25))
            }
            
            if(self.damagedWheel == 2 || self.damagedWheel == 4)
            {
                self.carObject?.run(SKAction.rotate(toAngle: (-1)*(5 * (CGFloat.pi/180)), duration: 0.25))
            }
        }
    }
    
    
    /*
     
     Touches processing
     
    */
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        //for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for t in touches
        {
            self.touchUp(at: t.location(in: self))
            
            if t == touchObject
            {
                touchObject = nil
                haveTouch = false;
                if !hasDamagedWheel
                {
                    if steeringAnimationsCounter == 0
                    {
                        self.carObject?.run(SKAction.rotate(toAngle: 0, duration: 0.25), completion: { })
                    }
                }
                else
                {
                    self.shiftCar()
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        //for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        touchObject = touches.first;
        haveTouch = true;
    }
    
    
    /*
     
     Called when touch event ends...
     
     */
    
    func touchUp(at : CGPoint)
    {
        if(at.x < pauseButton!.position.x && at.y > pauseButton!.position.y)
        {
            self.scene?.isPaused = true
            self.gamePaused = true
            
            showPauseScreenIfNeeded()
        }
    }
    
    
    /*
     
     Show pause screen if needed (do not show 2 or more)
     
     */
    
    func showPauseScreenIfNeeded()
    {
        if(!pauseScreenIsShownig)
        {
            pauseScreenIsShownig = true
            self.scene?.isPaused = true
            self.gamePaused = true
            
            //stop the music (at global mixer)
            self.scene!.audioEngine.mainMixerNode.outputVolume = 0;
            
            let storyboard0: UIStoryboard = UIStoryboard(name: "menu", bundle: nil)
            let vc0 = storyboard0.instantiateViewController(withIdentifier: "pauseScreenVC") as! pauseScreenViewController
            
            vc0.gameVCReference = self.vcReference
            
            self.vcReference?.present(vc0, animated: false, completion: nil)
        }
    }
    
    
    /*
    
     updates hud odometer with actual kilometers
     
    */
    
    func hudUpdateOdometer(odo : SKLabelNode, km : CGFloat)
    {
        if(km < 1)
        {
            odo.text = String(format: "%.0f", Double(km * 1000)) + " " + NSLocalizedString("REGIONAL_METERS", comment: "m");
        }
        else if(km < 10)
        {
            odo.text = String(format: "%.2f", Double(km)) + " " + NSLocalizedString("REGIONAL_KILOMETERS", comment: "km");
        }
        else if(km < 100)
        {
            odo.text = String(format: "%.1f", Double(km)) + " " + NSLocalizedString("REGIONAL_KILOMETERS", comment: "km");
        }
        else
        {
            odo.text = String(format: "%.0f", Double(km)) + " " + NSLocalizedString("REGIONAL_KILOMETERS", comment: "km");
        }
    }
    
    
    /*
     
     Get top VC to display new screen
     
    */
    
    func getTopVC() -> UIViewController
    {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        
        while (topController.presentedViewController != nil)
        {
            topController = topController.presentedViewController!
        }
        
        return topController
    }
    
    
    /*
    
     Shows tutorial on first game stratup
     
    */
    
    func showTutorialIfNeeded()
    {
        if(sVarsShared.firstStartup == true)
        {
            sVarsShared.firstStartup = false
            gameInTutorialMode = true
            
            //some analytics
            Analytics.logEvent(AnalyticsEventTutorialBegin, parameters: [:])
            
            //add tutorial objects
            fadeRectangle = SKShapeNode(rectOf: CGSize(width: self.size.width * ipadUpscaleRate, height: self.size.height * iphoneXUpscaleRate))
            fadeRectangle!.alpha = 0
            fadeRectangle!.fillColor = .black
            fadeRectangle!.zPosition = 25
            self.addChild(fadeRectangle!)
            
            
            //background fade in
            fadeRectangle?.run(SKAction.fadeAlpha(by: 0.75, duration: 1))
            
            
            //SCREEN 1 - Swipe to steer
            let tutorialImage = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "tutorSwipeToSteer")), size: CGSize(width: 450, height: 450))
            tutorialImage.alpha = 0;
            tutorialImage.zPosition = 26
            self.addChild(tutorialImage)
            
            let lbl = SKLabelNode(text: NSLocalizedString("TUTORIAL_SWIPE", comment: "Swipe"))
            lbl.position = CGPoint(x: 0, y: -400)
            lbl.zPosition = 26
            lbl.alpha = 0
            lbl.fontSize = 40
            lbl.fontName = "Marker Felt Wide"
            lbl.fontColor = UIColor(displayP3Red: 0.79, green: 0.79, blue: 0.79, alpha: 1)
            self.addChild(lbl)
            
            //show screen
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1))
            {
                tutorialImage.run(SKAction.fadeIn(withDuration: 0.5))
                lbl.run(SKAction.fadeIn(withDuration: 0.5))
            }
            
            //hide screen and show SCREEN 2
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4))
            {
                tutorialImage.run(SKAction.fadeOut(withDuration: 0.5), completion: {
                    tutorialImage.texture = SKTexture(image: #imageLiteral(resourceName: "tutorTapToSteer"))
                    tutorialImage.run(SKAction.fadeIn(withDuration: 0.5))
                })
                
                lbl.run(SKAction.fadeOut(withDuration: 0.5), completion: {
                    lbl.text = NSLocalizedString("TUTORIAL_TAP", comment: "Tap")
                    lbl.run(SKAction.fadeIn(withDuration: 0.5))
                })
            }
            
            
            //SCREEN 2 - Tap to steer
            //hide screen
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(8))
            {
                tutorialImage.run(SKAction.fadeOut(withDuration: 0.5), completion: {
                    tutorialImage.texture = SKTexture(image: #imageLiteral(resourceName: "rubleLogo"))
                    tutorialImage.size = CGSize(width: 200, height: 200)
                    tutorialImage.run(SKAction.fadeIn(withDuration: 0.5))
                })
                
                lbl.run(SKAction.fadeOut(withDuration: 0.5), completion: {
                    lbl.text = NSLocalizedString("TUTORIAL_COINS", comment: "Coins")
                    lbl.run(SKAction.fadeIn(withDuration: 0.5))
                })
            }
            
            
            //SCREEN 3 - Rubles
            //hide screen
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(11))
            {
                tutorialImage.run(SKAction.fadeOut(withDuration: 0.5), completion: {
                    tutorialImage.texture = SKTexture(image: #imageLiteral(resourceName: "tutorObstacles"))
                    tutorialImage.size = CGSize(width: 500, height: 460)
                    tutorialImage.run(SKAction.fadeIn(withDuration: 0.5))
                    //tutorialImage.removeFromParent()
                })
                
                lbl.run(SKAction.fadeOut(withDuration: 0.5), completion: {
                    lbl.text = NSLocalizedString("TUTORIAL_OBS", comment: "Coins")
                    lbl.run(SKAction.fadeIn(withDuration: 0.5))
                    //lbl.removeFromParent()
                })
            }
            
            //SCREEN 4 - obstacles
            //hide and delete
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(16))
            {
                tutorialImage.run(SKAction.fadeOut(withDuration: 0.5), completion: {
                    tutorialImage.removeFromParent()
                })
                
                lbl.run(SKAction.fadeOut(withDuration: 0.5), completion: {
                    lbl.removeFromParent()
                })
            }
            
            //background fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(17))
            {
                self.fadeRectangle?.run(SKAction.fadeOut(withDuration: 1), completion: {
                    self.gameInTutorialMode = false
                    
                    Analytics.logEvent(AnalyticsEventTutorialComplete, parameters: [:])
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1))
                    {
                        self.notifyController?.showString(message: NSLocalizedString("SURVIVE", comment: ""))
                    }
                })
            }
            
        }
    }
    
    
    /*
     
     show blank white screen, for correct exit
     
     */
    
    public func goBlank()
    {
        fadeRectangle = SKShapeNode(rectOf: CGSize(width: self.size.width * ipadUpscaleRate, height: self.size.height * iphoneXUpscaleRate))
        fadeRectangle!.alpha = 1
        fadeRectangle!.fillColor = .white
        fadeRectangle!.zPosition = 99
        self.addChild(fadeRectangle!)
    }
    
    
    /*
     
     Makes high score visuals
     
    */
    
    func updateHighScoreVisuals()
    {
        var vHeight = sceneSizeHeight / 2;
        var vWidth = sceneSizeWidth / 2
        if (iphoneXAdaptationNeeded) { vHeight *= iphoneXUpscaleRate; }
        if (UIDevice.current.userInterfaceIdiom == .pad) { vWidth *= ipadUpscaleRate }
        
        if highScoresVisualsTimeout > 0
        {
            highScoresVisualsTimeout = highScoresVisualsTimeout - 1;
        }
        
        let currentList = highScoresManager.getScoreObjectByType(highScoresGameType)
        
        //spawn new objects
        for hsObj in currentList
        {
            if highScoresVisualsTimeout == 0 && (fabs(hsObj.value - Float(kilometers)) < 0.001)
            {
                highScoresVisualsTimeout = 32;
                
                let newVisual = highScoreVisualEntity(screenHeight: vHeight, screenWidth: vWidth, highScore: hsObj.name)
                
                self.addChild(newVisual.gradientSprite)
                self.addChild(newVisual.textLabel)
                
                highScoreVisuals.append(newVisual)
            }
        }
        
        //move them down
        for visual in highScoreVisuals { visual.tickDown(velocity: carVelocity) }
        
        //delete when off-screen
        for visual in highScoreVisuals
        {
            if (!visual.isInScreenBounds(bounds: vHeight))
            {
                //print("Deleted")
                
                visual.gradientSprite.removeFromParent()
                visual.textLabel.removeFromParent()
                
                if let index = highScoreVisuals.index(where: { r in r.gradientSprite == visual.gradientSprite }) 
                {
                    highScoreVisuals.remove(at: index)
                }
            }
        }
    }
    
    
    /*
    
     Creates, sets, and preloads particle systems
     
    */
    
    func initializeParticleSystems()
    {
        //SPARKS
        let path = Bundle.main.path(forResource: "carSparks", ofType: "sks")
        sparkParticle = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as? SKEmitterNode
        
        sparkParticle!.position = CGPoint(x: 0, y: 0)
        sparkParticle!.name = "sparkParticle"
        sparkParticle!.targetNode = self.scene
        sparkParticle!.zPosition = 7
        
        //SMOKES
        let path2 = Bundle.main.path(forResource: "carSmoke", ofType: "sks")
        smokeParticle = NSKeyedUnarchiver.unarchiveObject(withFile: path2!) as? SKEmitterNode
        
        smokeParticle!.position = CGPoint(x: 0, y: 0)
        smokeParticle!.name = "smokeParticle"
        smokeParticle!.targetNode = self.scene
        smokeParticle!.zPosition = 6
        
        //IMPACT EXPLOSION
        let pathImpact = Bundle.main.path(forResource: "impact", ofType: "sks")
        impactParticle = NSKeyedUnarchiver.unarchiveObject(withFile: pathImpact!) as? SKEmitterNode
        
        impactParticle!.position = CGPoint(x: 0, y: 0)
        impactParticle!.name = "impactParticle"
        impactParticle!.targetNode = self.scene
        impactParticle!.zPosition = 11
        
        //IMPACT SMOKES
        let pathImpactSmokes = Bundle.main.path(forResource: "impactSmokes", ofType: "sks")
        impactSmokesParticle = NSKeyedUnarchiver.unarchiveObject(withFile: pathImpactSmokes!) as? SKEmitterNode
        
        impactSmokesParticle!.position = CGPoint(x: 0, y: 0)
        impactSmokesParticle!.name = "impactSmokesParticle"
        impactSmokesParticle!.targetNode = self.scene
        impactSmokesParticle!.zPosition = 10
        
        //TOTALED SMOKE
        let pathTotalSmokes = Bundle.main.path(forResource: "totaledSmokes", ofType: "sks")
        totaledParticle = NSKeyedUnarchiver.unarchiveObject(withFile: pathTotalSmokes!) as? SKEmitterNode
        
        totaledParticle!.position = CGPoint(x: 0, y: 0)
        totaledParticle!.name = "totaledSmokesParticle"
        totaledParticle!.targetNode = self.scene
        totaledParticle!.zPosition = 7
        
        //WINTER MODE SNOW
        let pathSnow = Bundle.main.path(forResource: "snow", ofType: "sks")
        snowParticle = NSKeyedUnarchiver.unarchiveObject(withFile: pathSnow!) as? SKEmitterNode
        
        var yPos = sceneSizeHeight/2+16;
        if(self.iphoneXAdaptationNeeded) { yPos *= iphoneXUpscaleRate }
        
        snowParticle!.position = CGPoint(x: 0, y: yPos)
        snowParticle!.name = "snowParticle"
        snowParticle!.targetNode = self.scene
        snowParticle!.zPosition = 12
        
        //preload
        //Sprite kit has not implemented preload method on emmiters
        //So just add it to a scene while its invisilble :)
        preloadSequenceActive = true
        self.addChild(sparkParticle!)
        self.addChild(smokeParticle!)
        self.addChild(impactParticle!)
        self.addChild(impactSmokesParticle!)
        self.addChild(totaledParticle!)
        self.addChild(snowParticle!)
        print("Particle Systems Preload Sequence Start")
    }
    
    
    /*
    
     Checks for preload cleanup pending and perform it
     
    */
    
    func preloadParticlesIfNeeded()
    {
        //preload
        if preloadSequenceActive
        {
            sparkParticle!.removeFromParent()
            sparkParticle!.resetSimulation()
            smokeParticle!.removeFromParent()
            smokeParticle!.resetSimulation()
            impactParticle!.removeFromParent()
            impactParticle!.resetSimulation()
            impactSmokesParticle!.removeFromParent()
            impactSmokesParticle!.resetSimulation()
            totaledParticle!.removeFromParent()
            totaledParticle!.resetSimulation()
            snowParticle!.removeFromParent()
            snowParticle!.resetSimulation()
            print("Particle Systems Preload Sequence End");
            preloadSequenceActive = false;
        }
    }
    
    
    /*
    
     Initializes nightmode texture mask
     
    */
    
    func initNightmode()
    {
        //Create night mask sprite
        nightMaskTexture = SKTexture(image: #imageLiteral(resourceName: "nightMask"))
        nightMask = SKSpriteNode(texture: nightMaskTexture)
        nightMask!.zPosition = 6
        nightMask?.size = CGSize(width: 4200, height: 4000)
        nightMask!.anchorPoint = CGPoint(x: 0.5, y: 0.435)
        self.addChild(nightMask!)

        //Create darkness mask
        nightDark = SKTexture(image: #imageLiteral(resourceName: "darkness"))
        nightDark?.preload { /* lel */ }
        
        //Fary na devyatke))
        if (isFaryEnabled)
        {
            leftFara?.run(SKAction.fadeAlpha(to: 0.75, duration: 3))
            rightFara?.run(SKAction.fadeAlpha(to: 0.75, duration: 3))
        }
    }
    
    
    /*
     
     Updates uniforms on loaded shaders
     
    */
    
    func updateNightmode()
    {
        if nightMode
        {
            //smoothing rotating angle
            let shaderRotation = (carObject!.zRotation) + ((carObject!.zRotation - carSavedRotation));
            carSavedRotation = carObject!.zRotation;
            
            
            if (!headlightOn)
            {
                //carY = self.scene!.frame.height * 2;
                nightMask?.texture = nightDark
                if(isFaryEnabled)
                {
                    leftFara?.alpha = 0
                    rightFara?.alpha = 0
                }
            }
            else
            {
                
                //sets position
                nightMask?.position = carObject!.position
                nightMask?.zRotation = shaderRotation
            }
            
        }
    }
    
    
    /*
    
     Bonus actions logic
     
    */
    
    func updateBonuses()
    {
        //SUPERSPEED
        if(superspeedModeTimer < 1)
        {
            superspeedMode = false;
            if(!whitescreenTimerIsActive) { carVelocity = speedLimit; }
            superspeedModeTimer = 2;
            hudBonusProgressBarBackground?.alpha = 0
            hudBonusProgressBar?.alpha = 0;
            hudBonusProgressBarIndicator?.alpha = 0
        }
        
        if(superspeedMode && hitCounter < 2 && !whitescreenTimerIsActive)
        {
            carVelocity = 31.35;
            speedLimit = 31.35;
        } //228))))
        
        if(superspeedMode)
        {
            superspeedModeTimer -= 1;
        }
        
        if(superspeedMode)
        {
            updateProgessBarByScaleOfOne(scale: (CGFloat(superspeedModeTimer) / CGFloat(300)))
        }
        
        //GOD MODE
        if(godmodeMode) { godmodeTimer -= 1; }
        
        if(godmodeMode && godmodeTimer == 999)
        {
            if(nightMode)
            {
                let nightSeq = SKAction.sequence([SKAction.colorize(withColorBlendFactor: 0.1, duration: 0.5), SKAction.colorize(withColorBlendFactor: 0.75, duration: 0.5)])
                
                let repeatebleAction = SKAction.repeat(nightSeq, count: 16)
                carObject?.run(repeatebleAction)
                
            }
            else
            {
                let nightSeq = SKAction.sequence([SKAction.fadeAlpha(to: 0.5, duration: 0.5), SKAction.fadeAlpha(to: 1, duration: 0.5)])
                
                let repeatebleAction = SKAction.repeat(nightSeq, count: 16)
                carObject?.run(repeatebleAction)
            }
        }
        
        if(godmodeTimer < 1)
        {
            godmodeMode = false;
            godmodeTimer = 2;
            hudBonusProgressBarBackground?.alpha = 0
            hudBonusProgressBar?.alpha = 0;
            hudBonusProgressBarIndicator?.alpha = 0
        }
        
        if(!godmodeMode)
        {
            carObject?.alpha = 1;
            
            if nightMode
            {
                carObject?.colorBlendFactor = 0.75
            }
        }
        
        if(godmodeMode)
        {
            updateProgessBarByScaleOfOne(scale: (CGFloat(godmodeTimer) / CGFloat(1000.0)))
        }

    }
    
    
    
    /*
    
     Bonus progress bar initialization
     
    */
    
    func initProgressBar()
    {
        //some loading indicator stuff
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: 0, y: 0), radius: 50, startAngle: 1.5707, endAngle: -3.1415 - 1.5707, clockwise: true)
        
        hudBonusProgressBarBackground = SKShapeNode(path: path, centered: true);
        hudBonusProgressBarBackground!.position = CGPoint(x: 0, y: -600)
        hudBonusProgressBarBackground!.zPosition = 24
        hudBonusProgressBarBackground!.strokeColor = .gray
        hudBonusProgressBarBackground!.lineWidth = 9
        
        hudBonusProgressBar = SKShapeNode(path: path, centered: true);
        hudBonusProgressBar!.position = CGPoint(x: 0, y: -600)
        hudBonusProgressBar!.zPosition = 24
        hudBonusProgressBar!.strokeColor = .white
        hudBonusProgressBar!.lineWidth = 7.5
        
        hudBonusProgressBarIndicator = SKSpriteNode(texture: roadTextureAtlas.textureNamed("powerups_0"))
        hudBonusProgressBarIndicator?.position = CGPoint(x: 0, y: -600)
        hudBonusProgressBarIndicator?.zPosition = 24
        
        if(iphoneXAdaptationNeeded)
        {
            hudBonusProgressBar?.position.y -= 95;
            hudBonusProgressBarBackground?.position.y -= 95;
            hudBonusProgressBarIndicator!.position.y -= 95;
        }
        
        hudBonusProgressBarBackground?.alpha = 0;
        hudBonusProgressBar?.alpha = 0;
        hudBonusProgressBarIndicator?.alpha = 0;
        
        self.addChild(hudBonusProgressBarBackground!)
        self.addChild(hudBonusProgressBar!)
        self.addChild(hudBonusProgressBarIndicator!)
    }
    
    
    /*
    
     Shows progress bar
     
    */
    
    func showProgressBarFor(bonus : String)
    {
        var bonusSize = CGSize()
        
        if(bonus == "powerups_0") { bonusSize = CGSize(width: 54, height: 72) }
        else { bonusSize = CGSize(width: 83, height: 54) }
        
        hudBonusProgressBarIndicator?.texture = roadTextureAtlas.textureNamed(bonus)
        hudBonusProgressBarIndicator!.size = bonusSize
        
        hudBonusProgressBarBackground?.run(SKAction.fadeIn(withDuration: 0.65))
        hudBonusProgressBar?.run(SKAction.fadeIn(withDuration: 0.65))
        hudBonusProgressBarIndicator?.run(SKAction.fadeIn(withDuration: 0.65))
    }
    
    
    /*
    
     Progress bar for bonus actions update action
     
    */
    
    func updateProgessBarByScaleOfOne(scale: CGFloat)
    {
        let startAngle : CGFloat = 1.5707;
        let endAngle : CGFloat = startAngle - ((2 * 3.1415) * scale)
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: 0, y: 0), radius: 50, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        hudBonusProgressBarBackground!.path = path
        hudBonusProgressBar!.path = path
    }
    
    
    /*
    
     Initializes winter mode
     
    */
    
    func initWinterMode()
    {
        backgroundColor = .white
        roadObject?.color = .lightGray
        roadShoulders?.color = .white
        roadBackground!.color = .white
        pauseButton?.color = .gray
        pauseButton?.colorBlendFactor = 0.5
        roadLineRight?.color = UIColor.init(red: 0.86, green: 0.86, blue: 0.86, alpha: 1)
        roadLineLeft?.color = UIColor.init(red: 0.86, green: 0.86, blue: 0.86, alpha: 1)
    }
}
