//
//  defeatScreenViewController.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 05.10.2018.
//  Copyright © 2018 Muxa Mot. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import Firebase

class defeatScreenViewController: UIViewController
{
    //DATA:
   
    @IBOutlet var brokenCarImage : UIImageView?
    @IBOutlet var rubleLogoImage : UIImageView?
    @IBOutlet var phraseString : UILabel?
    @IBOutlet var youGainString : UILabel?
    @IBOutlet var pointsGained : UILabel?
    @IBOutlet var saveMeButton : UIButton?
    @IBOutlet var defeatButton : UIButton?
    @IBOutlet var defeatButtonHorizontalConstraint : NSLayoutConstraint?

    
    override var prefersStatusBarHidden: Bool { return true; }
    public var gameVCReference : UIViewController?
    
    public var isRevivable : Bool = true
    public var revivePrice : Int = 0
    public var isStreetlight : Bool = false
    
    var player : AVAudioPlayer!
    var isScreenFaded : Bool = false
    var adPresentationNeeded : Bool = false
    
    var russianPhrasesList = [ NSLocalizedString("DEFEAT_1", comment: "1"),
                               NSLocalizedString("DEFEAT_2", comment: "2"),
                               NSLocalizedString("DEFEAT_3", comment: "3"),
                               NSLocalizedString("DEFEAT_4", comment: "4"),
                               NSLocalizedString("DEFEAT_5", comment: "5"),
                               NSLocalizedString("DEFEAT_6", comment: "6"),
                               NSLocalizedString("DEFEAT_7", comment: "7")
    ]
    
    //METHODS:

    /*
     
     Sound player
     
     */
    
    func playSound()
    {
        if(sVarsShared.soundEnabled)
        {
            let trackname = "track" + String(arc4random_uniform(2) + 6)
            guard let path = Bundle.main.path(forResource: trackname, ofType: "mp3")else{return}
            let soundURl = URL(fileURLWithPath: path)
            player = try? AVAudioPlayer(contentsOf: soundURl)
            if (player != nil)
            {
                player.prepareToPlay()
                player.volume = 0.0;
                player.numberOfLoops = 1
                player.play()
                player.setVolume(0.4, fadeDuration: 0.5)
            }
        }
    }
    
    
    /*
    
     Called when view is loaded and ready to appear
     
    */
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if(isStreetlight)
        {
            phraseString?.text = NSLocalizedString("DEFEAT_STOLB", comment: "Stolb");
        }
        else
        {
            let index = arc4random_uniform(UInt32(russianPhrasesList.count))
            phraseString?.text = russianPhrasesList[Int(index)]
        }
        
        let gvc = self.gameVCReference as! GameViewController
        let scene = gvc.getScene() as! GameScene
        scene.pauseScreenIsShownig = true;
        
        pointsGained?.text = String(scene.points)
        
        if (!isRevivable)
        {
            saveMeButton?.isHidden = true;
            defeatButtonHorizontalConstraint?.constant = 0;
            self.view.layoutIfNeeded()
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        phraseString?.center.y -= self.view.bounds.height
        brokenCarImage?.center.y -= self.view.bounds.height
        youGainString?.alpha = 0
        pointsGained?.alpha = 0
        rubleLogoImage?.alpha = 0
        saveMeButton?.center.x -= self.view.bounds.width
        if(self.isRevivable) { defeatButton?.center.x += self.view.bounds.width }
        else { defeatButton?.center.y += self.view.bounds.height }
        
        UIView.animate(withDuration: 0.3, animations:
        {
            self.phraseString?.center.y += self.view.bounds.height
            self.brokenCarImage?.center.y += self.view.bounds.height
            self.youGainString?.alpha = 1
            self.pointsGained?.alpha = 1
            self.rubleLogoImage?.alpha = 1
            self.saveMeButton?.center.x += self.view.bounds.width
            if(self.isRevivable) { self.defeatButton?.center.x -= self.view.bounds.width }
            else { self.defeatButton?.center.y -= self.view.bounds.height }
        })
    
        if(!isScreenFaded)
        {
            playSound()
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func saveMeButtonTapped()
    {
        if (player != nil && player.isPlaying) { player.stop() }
        
        //present ad screen view controller
        if (sharedAdsManager.interstitialAd.hasBeenUsed == false && sharedAdsManager.interstitialAd.isReady == true)
        {
            let storyboard: UIStoryboard = UIStoryboard(name: "menu", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "adScreenVC") as! adScreenViewController
            
            vc.modalPresentationStyle = .overFullScreen;
            vc.modalTransitionStyle = .flipHorizontal;
            vc.completionHandler = {
                let gvc = self.gameVCReference as! GameViewController
                let scene = gvc.getScene() as! GameScene
                scene.restoreAfterCarAccident()
                scene.pauseScreenIsShownig = false;
                self.dismiss(animated: false, completion: nil)
            }
            
            self.present(vc, animated: true, completion: nil)
            return;
        }
        
        Analytics.logEvent("player_revive", parameters: [:])
        
        let gvc = self.gameVCReference as! GameViewController
        let scene = gvc.getScene() as! GameScene
        scene.restoreAfterCarAccident()
        scene.pauseScreenIsShownig = false;
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func defeatButtonTapped()
    {
        if (player != nil && player.isPlaying) { player.stop() }
        
        let gvc = self.gameVCReference as! GameViewController
        let scene = gvc.getScene() as! GameScene
        
        if (sharedAdsManager.interstitialAd.hasBeenUsed == false && sharedAdsManager.interstitialAd.isReady == true)
        { self.adPresentationNeeded = true  }
        else
        { self.adPresentationNeeded = false }
        
        Analytics.logEvent("game_session_end", parameters: [ "endpoint" : "Defeat Screen"])
        
        //high scores manager
        if(scene.highScoresManager.checkHighScore(kms: Float(scene.kilometers), type: scene.highScoresGameType))
        {
            let storyboard0: UIStoryboard = UIStoryboard(name: "menu", bundle: nil)
            let vc0 = storyboard0.instantiateViewController(withIdentifier: "addHighScoreVC") as! addHighScoreViewController
            
            vc0.fromDefeatScreen = true
            vc0.defeatVC = self
            vc0.kilometersInRecord = Float(scene.kilometers)
            vc0.scoresManager = scene.highScoresManager
            vc0.modalPresentationStyle = .overFullScreen
            vc0.modalTransitionStyle = .crossDissolve
            
            self.present(vc0, animated: true, completion: nil)
            
            return;
        }
        
        gracefullyDismiss();
    }
    
    
    /*
    
     Exits game and this VC correcly
     
    */
    
    func gracefullyDismiss()
    {
        let gvc = self.gameVCReference as! GameViewController
        let scene = gvc.getScene() as! GameScene
        scene.goBlank()
        
        //present ad if needed
        if(adPresentationNeeded)
        {
            adPresentationNeeded = false;
            presentAdViewControllerIfNeeded(scene: scene)
            return;
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute:
        {
            self.dismiss(animated: false, completion:
            {
                scene.pauseScreenIsShownig = false;
                
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
    
     Presents ad view controller if needed
     
    */
    
    func presentAdViewControllerIfNeeded(scene : GameScene)
    {
        //present ad screen view controller
        if (sharedAdsManager.interstitialAd.hasBeenUsed == false && sharedAdsManager.interstitialAd.isReady == true)
        {
            let storyboard: UIStoryboard = UIStoryboard(name: "menu", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "adScreenVC") as! adScreenViewController
            
            vc.modalPresentationStyle = .overFullScreen;
            vc.modalTransitionStyle = .flipHorizontal;
            vc.completionHandler = { self.goBlank(); self.gracefullyDismiss(); }
            
            self.present(vc, animated: true, completion: nil)
            return;
        }
    }
    
    
    /*
    
     Blank VC's screen
     
    */
    
    func goBlank()
    {
        brokenCarImage!.alpha = 0
        rubleLogoImage!.center.y += self.view.bounds.height
        phraseString!.alpha = 0
        youGainString!.center.y += self.view.bounds.height
        pointsGained!.center.y += self.view.bounds.height
        saveMeButton!.alpha = 0
        defeatButton!.alpha = 0
        isScreenFaded = true
    }
    
}
