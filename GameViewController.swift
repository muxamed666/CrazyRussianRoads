//
//  GameViewController.swift
//  Crazy Russian Road
//
//  Created by Muxa Mot on 05.09.2018.
//  Copyright © 2018 Muxa Mot. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


/*

 Presents ViewController for Game Scene
 
*/

class GameViewController: UIViewController
{
    //DATA
    
    //1 - easy
    //2 - middle
    //3 - hard
    var difficultyLevel : Int = 0
    
    //METHODS
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene")
        {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene?
            {
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                sceneNode.vcReference = self
                
                //set difficulty level-related vars
                if difficultyLevel == 1
                {
                    sceneNode.winterMode = false
                    sceneNode.nightMode = false
                    sceneNode.repairPrice = 10
                    sceneNode.minimumRubleValue = 1
                    sceneNode.maximumRubleValue = 3
                }
                
                if difficultyLevel == 2
                {
                    sceneNode.winterMode = true
                    sceneNode.nightMode = false
                    sceneNode.repairPrice = 20
                    sceneNode.minimumRubleValue = 1
                    sceneNode.maximumRubleValue = 6
                }
                
                if difficultyLevel == 3
                {
                    sceneNode.winterMode = false
                    sceneNode.nightMode = true
                    sceneNode.repairPrice = 30
                    sceneNode.minimumRubleValue = 3
                    sceneNode.maximumRubleValue = 7
                }
                
                // Present the scene
                if let view = self.view as! SKView?
                {
                    view.presentScene(sceneNode)
                
                    view.ignoresSiblingOrder = true
                    view.shouldCullNonVisibleNodes = true
                    
                    if(sharedDataStorage.isInDebugMode)
                    {
                        view.showsFPS = true
                        view.showsNodeCount = true
                        view.showsDrawCount = true
                    }
                }
            }
        }
    }

    override var shouldAutorotate: Bool
    {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return .portrait
        }
        else
        {
            return .portrait
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    //self dismiss
    public func selfDismiss()
    {
        self.removeFromParentViewController()
        self.dismiss(animated: true, completion: nil)
        let v = self.view as! SKView
        v.presentScene(nil)
    }
    
    public func getScene() -> SKScene?
    {
        let view = self.view as! SKView
        return view.scene
    }
}
