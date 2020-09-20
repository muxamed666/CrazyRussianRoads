//
//  ingameNotifications.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 11.11.2018.
//  Copyright © 2018 Muxa Mot. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


/*

 Ingame notifications service
 
*/

class ingameNotifications
{
    var busy : Bool = false
    var background : SKSpriteNode
    var repair : SKSpriteNode
    var repairLogo : SKSpriteNode
    var repairText : SKLabelNode
    var textSprite : SKLabelNode
    
    let bgAlphaLevel : CGFloat = 0.5
    
    init(notificationsBackgound : SKSpriteNode, repairSignLogo : SKSpriteNode, repairSprite : SKSpriteNode, repairSpriteText : SKLabelNode, textLabel : SKLabelNode)
    {
        self.background = notificationsBackgound
        self.repair = repairSprite
        self.repairText = repairSpriteText
        self.textSprite = textLabel
        self.repairLogo = repairSignLogo
        
        self.background.alpha = 0
        self.repair.alpha = 0
        self.textSprite.alpha = 0;
    }
    
    
    //repair
    func showRepairSign(scoreNeeded : Int)
    {
        if busy
        {
            return
        }
        
        busy = true
        
        repairLogo.texture = SKTexture(image: #imageLiteral(resourceName: "repairLogo"));
        repairText.text = NSLocalizedString("REPAIR_1", comment: "repair str") + String(scoreNeeded) + NSLocalizedString("REPAIR_2", comment: "repair str");
        
        guard let bgFadeIn = SKAction(named: "notificationBgIn") else { return }
        guard let bgFadeOut = SKAction(named: "notificationBgOut") else { return }
        guard let blink = SKAction(named: "warningBlink") else { return }
        
        background.run(bgFadeIn)
        background.alpha = bgAlphaLevel
        
        repair.run(blink, completion:
            {
                self.background.run(bgFadeOut, completion: {
                    self.background.alpha = 0;
                    self.busy = false;
                });
            })
    }
    
    
    //text string out
    func showString(message : String)
    {
        if busy
        {
            return
        }
        
        busy = true
        
        guard let bgFadeIn = SKAction(named: "notificationBgIn") else { return }
        guard let bgFadeOut = SKAction(named: "notificationBgOut") else { return }
        guard let blink = SKAction(named: "warningBlink") else { return }
        
        textSprite.text = message
        
        background.run(bgFadeIn)
        background.alpha = bgAlphaLevel
        
        textSprite.run(blink, completion:
            {
                self.background.run(bgFadeOut, completion: {
                    self.background.alpha = 0;
                    self.busy = false;
                });
            })
    }
    
    
    //string and texture
    func showStringAndSign(message : String, sign : SKTexture)
    {
        if busy
        {
            return
        }
        
        busy = true
        
        //kostyl!!!
        let bckpWidth = repairLogo.size.width;
        repairLogo.size.width = repairLogo.size.width * 1.3;
        //kostyl!!!
        
        repairLogo.texture = sign;
        repairText.text = message;
        
        guard let bgFadeIn = SKAction(named: "notificationBgIn") else { return }
        guard let bgFadeOut = SKAction(named: "notificationBgOut") else { return }
        guard let blink = SKAction(named: "warningBlink") else { return }
        
        background.run(bgFadeIn)
        background.alpha = bgAlphaLevel
        
        repair.run(blink, completion:
            {
                self.background.run(bgFadeOut, completion:
                {
                    self.background.alpha = 0;
                    self.repairLogo.size.width = bckpWidth;
                    self.busy = false;
                });
        })
    }
    
}
