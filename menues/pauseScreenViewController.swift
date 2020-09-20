//
//  pauseScreenViewController.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 29.12.2018.
//  Copyright © 2018 Muxa Mot. All rights reserved.
//

import UIKit
import SpriteKit
import Firebase


class pauseScreenViewController: UIViewController
{

    //DATA:
    
    @IBOutlet var unpauseButton : UIButton!
    @IBOutlet var returnButton : UIButton!
    @IBOutlet var triangle : UIImageView!
    @IBOutlet var gamePausedLabel : UILabel!
    @IBOutlet var toggleSoundButton : UIButton!
    @IBOutlet var toggleVibroButton : UIButton!
    
    override var prefersStatusBarHidden: Bool { return true; }
    
    public var gameVCReference : UIViewController?
    
    //METHODS:
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //by default buttons is in "enabled" state
        if(sVarsShared.soundEnabled == false)
        {
            toggleSoundButton.setImage(#imageLiteral(resourceName: "menuSoundDisabled"), for: .normal)
        }
        
        if(sVarsShared.vibroEnabled == false)
        {
            toggleVibroButton.setImage(#imageLiteral(resourceName: "menuVibroDisabled"), for: .normal)
        }
        
        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool)
    {
        triangle.center.y -= self.view.bounds.height
        gamePausedLabel.center.y -= self.view.bounds.height
        toggleSoundButton.center.x -= self.view.bounds.width
        toggleVibroButton.center.x += self.view.bounds.width
        unpauseButton.center.y += self.view.bounds.height
        returnButton.center.y += self.view.bounds.height
        
        UIView.animate(withDuration: 0.3, animations:
            {
                self.triangle.center.y += self.view.bounds.height
                self.gamePausedLabel.center.y += self.view.bounds.height
                self.toggleSoundButton.center.x += self.view.bounds.width
                self.toggleVibroButton.center.x -= self.view.bounds.width
                self.unpauseButton.center.y -= self.view.bounds.height
                self.returnButton.center.y -= self.view.bounds.height
        })
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //unpause game and dissmiss
    @IBAction func unpauseButtonPressed()
    {
        let gvc = self.gameVCReference as! GameViewController
        let scene = gvc.getScene() as! GameScene
        scene.gamePaused = false
        scene.isPaused = false
        scene.pauseScreenIsShownig = false
        //get song back
        scene.audioEngine.mainMixerNode.outputVolume = 1;
        self.dismiss(animated: false, completion: nil)
    }
    
    //close game VC and go to menu
    @IBAction func returnButtonPressed()
    {
        let gvc = self.gameVCReference as! GameViewController
        let scene = gvc.getScene() as! GameScene
        
        if(scene.highScoresManager.checkHighScore(kms: Float(scene.kilometers), type: scene.highScoresGameType))
        {
            let storyboard0: UIStoryboard = UIStoryboard(name: "menu", bundle: nil)
            let vc0 = storyboard0.instantiateViewController(withIdentifier: "addHighScoreVC") as! addHighScoreViewController
            
            vc0.fromDefeatScreen = false
            vc0.pauseVC = self
            vc0.kilometersInRecord = Float(scene.kilometers)
            vc0.scoresManager = scene.highScoresManager
            vc0.modalPresentationStyle = .overFullScreen
            vc0.modalTransitionStyle = .crossDissolve
            
            self.present(vc0, animated: true, completion: nil)
            
            return;
        }
        
        Analytics.logEvent("game_session_end", parameters: [ "endpoint" : "Pause Screen"])
        
        gracefullyDismiss();
    }
    

    /*
    
     Called when user taps sound button
     
    */
    
    @IBAction func toggleSoundButtonPressed()
    {
        sVarsShared.soundEnabled = !sVarsShared.soundEnabled;
        if(sVarsShared.soundEnabled)
        { toggleSoundButton.setImage(#imageLiteral(resourceName: "menuSoundEnabled"), for: .normal) }
        else
        { toggleSoundButton.setImage(#imageLiteral(resourceName: "menuSoundDisabled"), for: .normal) }
    }
    
    
    /*
     
     Called when user taps sound button
     
    */
    
    @IBAction func toggleVibroButtonPressed()
    {
        sVarsShared.vibroEnabled = !sVarsShared.vibroEnabled;
        if(sVarsShared.vibroEnabled)
        { toggleVibroButton.setImage(#imageLiteral(resourceName: "menuVibroEnabled"), for: .normal) }
        else
        { toggleVibroButton.setImage(#imageLiteral(resourceName: "menuVibroDisabled"), for: .normal) }
    }
    
    
    /*
     
     Exits game and this VC correcly
     
    */
    
    func gracefullyDismiss()
    {
        let gvc = self.gameVCReference as! GameViewController
        let scene = gvc.getScene() as! GameScene
        scene.goBlank()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute:
        {
            self.dismiss(animated: false, completion:
            {
                scene.pauseScreenIsShownig = false
                    
                sVarsShared.totalPointsScore = sVarsShared.totalPointsScore + UInt(scene.points);
                if (Float(scene.kilometers) > sVarsShared.kilometersHighscore)
                {
                    sVarsShared.kilometersHighscore = Float(scene.kilometers)
                }
                
                Analytics.logEvent(AnalyticsEventEarnVirtualCurrency, parameters: [ "virtual_currency_name" : "Points", "value" : scene.points])
                
                sharedDataStorage.pointsPending = true
                sharedDataStorage.pointsToBeAnimated = UInt(scene.points)
                
                self.gameVCReference?.removeFromParentViewController()
                self.gameVCReference?.dismiss(animated: false, completion: nil)
                let v = self.gameVCReference?.view as! SKView
                v.presentScene(nil)
            })
        })

    }
    
    
    /*
    
     Blank VC's screen
     
    */
    
    func goBlank()
    {
        unpauseButton.alpha = 0;
        returnButton.alpha = 0;
        triangle.alpha = 0;
        gamePausedLabel.alpha = 0;
        toggleSoundButton.alpha = 0;
        toggleVibroButton.alpha = 0;
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
