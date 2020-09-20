//
//  camera.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 06.02.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


/*

 Extend SKCameraNode Class for camera operations
 
*/

extension SKCameraNode
{    
    func updateScaleFor(userInterfaceIdiom: UIUserInterfaceIdiom, ipadRatio : CGFloat, iphoneXRatio : CGFloat)
    {
        switch userInterfaceIdiom
        {
        case .phone:
            //Detect if its iphone X, XS and newer
            let heightRatio = (UIScreen.main.bounds.height / UIScreen.main.bounds.width) * 9;
            if(heightRatio > 19.2)
            {
                let zoomAction = SKAction.scale(to: iphoneXRatio, duration: 0.6)
                self.run(zoomAction)
            }
            else
            {
                //iPhone 5, 5S, 6 ......... 8, 8Plus
                let zoomAction = SKAction.scale(to: 1, duration: 0.6)
                self.run(zoomAction)
            }
            
            break
        case .pad:
            //self.setScale(ipadRatio);
            let zoomAction = SKAction.scale(to: ipadRatio, duration: 0.6)
            self.run(zoomAction)
            break
        default:
            self.setScale(1.0)
            break
        }
    }
}
