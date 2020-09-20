//
//  menuViewController.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 28.09.2018.
//  Copyright © 2018 Muxa Mot. All rights reserved.
//

import UIKit
import AVFoundation
import PersonalizedAdConsent
import GoogleMobileAds

class menuViewController: UIViewController
{
    //DATA
    @IBOutlet var roadButton : UIButton!
    @IBOutlet var carButton : UIButton!
    @IBOutlet var superButton : UIButton!
    @IBOutlet var taptoplayLabel : UILabel!
    @IBOutlet var shopButton : UIButton!
    @IBOutlet var settingsButton : UIButton!
    @IBOutlet var adBonusButton : UIButton!
    @IBOutlet var adBonusTransparentButton : UIButton!
    @IBOutlet var topFiveButton : UIButton!
    @IBOutlet var scoreContainer : UIView!
    @IBOutlet var scorePointsLabel : UILabel!
    @IBOutlet var scoreKilometersLabel : UILabel!
    @IBOutlet var menuBlackFadeRect : UIView!
    @IBOutlet var pointsGainView : UIView!
    @IBOutlet var pointsGainViewString : UILabel!
    
    override var prefersStatusBarHidden: Bool { return true; }
    
    private var player : AVAudioPlayer!
    private var isMusicPlaying : Bool = false
    
    //METHODS

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     
     Start sound player
     
    */
    
    func playBackgroundMusic()
    {
        stopBackgroundMusic()
        
        if(!self.isMusicPlaying)
        {
            guard let path = Bundle.main.path(forResource: "track3_a", ofType: "mp3")else{return}
            let soundURl = URL(fileURLWithPath: path)
            player = try? AVAudioPlayer(contentsOf: soundURl)
            if (player != nil)
            {
                player.prepareToPlay()
                if(sVarsShared.soundEnabled) { player.volume = 0.2; } else { player.volume = 0; }
                player.numberOfLoops = 64;
                player.play()
                self.isMusicPlaying = true
            }
        }
    }
    
    
    /*
     
     Stop sound player
     
    */
    
    func stopBackgroundMusic()
    {
        if(self.isMusicPlaying)
        {
            if(player != nil)
            {
                if(player.isPlaying)
                {
                    player.stop()
                    self.isMusicPlaying = false
                }
                else
                {
                    self.isMusicPlaying = false
                }
            }
            else
            {
                self.isMusicPlaying = false
            }
        }
    }
    
    
    /*
    
     Set background music volume
     
    */
    
    func setBackgroundMusicVolume(_ vol : Float)
    {
        player.volume = vol
    }
    
    
    /*
    
     On view show
     
    */
    
    override func viewWillAppear(_ animated: Bool)
    {
        setScreenCounters()
        playBackgroundMusic()
        
        showDailyBonusScreenIfNeeded()
        invokeGainigAnimationIfNeeded()
        
        self.carButton.center.y -= view.bounds.height
        self.roadButton.center.y += view.bounds.height
        self.shopButton.center.x -= view.bounds.width
        self.settingsButton.center.x += view.bounds.width
        self.adBonusButton.center.y += view.bounds.height
        self.topFiveButton.center.x += view.bounds.width
        self.scoreContainer.alpha = 0
        self.taptoplayLabel.alpha = 0
        self.superButton.alpha = 0
        self.adBonusTransparentButton.alpha = 0
        
        self.pointsGainView.alpha = 0
        self.pointsGainView.isHidden = true
        
        self.menuBlackFadeRect.isHidden = true;
        self.menuBlackFadeRect.translatesAutoresizingMaskIntoConstraints = false;
        
        let tc = NSLayoutConstraint(item: menuBlackFadeRect, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let lc = NSLayoutConstraint(item: menuBlackFadeRect, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0)
        let rc = NSLayoutConstraint(item: menuBlackFadeRect, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
        let bc = NSLayoutConstraint(item: menuBlackFadeRect, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraints([tc, lc, rc, bc]);
        
        UIView.animate(withDuration: 1.0, delay: 0, options: [],
        animations: {
            self.roadButton.center.y -= self.view.bounds.height
        }, completion: nil)
        
        UIView.animate(withDuration: 1.0, delay: 1, options: [],
                       animations: {
                        self.carButton.center.y += self.view.bounds.height
        }, completion:
            {   state in
                
                UIView.animate(withDuration: 0.5, delay: 0.5, options: [],
                               animations: {
                                self.carButton.center.x += 4;
                }, completion: nil)
                
                UIView.animate(withDuration: 1.0, delay: 1, options: [.repeat, .autoreverse],
                               animations: {
                                self.carButton.center.x -= 8;
                }, completion: nil)
            })
        
        UIView.animate(withDuration: 0.5, delay: 2, options: [],
                       animations: {
                        self.shopButton.center.x += self.view.bounds.width
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 2, options: [],
                       animations: {
                        self.settingsButton.center.x -= self.view.bounds.width
        }, completion: nil)

        UIView.animate(withDuration: 0.5, delay: 2, options: [],
                       animations: {
                        self.adBonusButton.center.y -= self.view.bounds.height
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 2, options: [],
                       animations: {
                        self.scoreContainer.alpha = 1
                        self.topFiveButton.center.x -= self.view.bounds.width
        }, completion: nil)
        
        UIView.animate(withDuration: 1.0, delay: 2.5, options: [.repeat, .autoreverse],
                       animations: {
                       self.taptoplayLabel.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 2.5, options: [],
                       animations: {
                        self.superButton.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 2.5, options: [],
                       animations: {
                        self.adBonusTransparentButton.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 0.8, delay: 2.5, options: [.repeat, .autoreverse],
                       animations: {
                        self.adBonusButton.transform = self.adBonusButton.transform.scaledBy(x: 0.95, y: 0.95)
            }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3))
        {
            if(sharedDataStorage.gdprAskNeeded)
            {
                guard let privacyUrl = URL(string: "http://crr-game.motylenok.com/privacy_policy.html"),
                    let form = PACConsentForm(applicationPrivacyPolicyURL: privacyUrl) else {
                        print("incorrect privacy URL.")
                        return
                }
                
                form.shouldOfferPersonalizedAds = true
                form.shouldOfferNonPersonalizedAds = true
                form.shouldOfferAdFree = false

                form.load {(_ error: Error?) -> Void in
                    print("GDPR form load complete.")
                    if let error = error {
                        // Handle error.
                        print("Error loading form: \(error.localizedDescription)")
                    } else {
                        form.present(from: self) { (error, userPrefersAdFree) in
                            if let error = error {
                                // Handle error.
                                print("Error in presenting GDPR Form")
                                print(error)
                            } else if userPrefersAdFree {
                                // User prefers to use a paid version of the app.
                            } else {
                                // Check the user's consent choice.
                                let status =
                                    PACConsentInformation.sharedInstance.consentStatus
                                
                                if(status == PACConsentStatus.nonPersonalized)
                                {
                                    let request = GADRequest()
                                    let extras = GADExtras()
                                    extras.additionalParameters = ["npa": "1"]
                                    request.register(extras)
                                }
                                
                                //Google AdMob init
                                GADMobileAds.sharedInstance().start(completionHandler:
                                {
                                    googleResult in
                                    print("Google AdMob Initialized")
                                    
                                    sharedAdsManager.createAndLoadRewardedAd()
                                })
                            }
                        }

                    }
                }

            }
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func gameButtonTapped(sender : AnyObject)
    {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "difficultySelectorVC") as! difficultySelectorViewController
        
        vc.modalPresentationStyle = .overFullScreen;
        vc.modalTransitionStyle = .crossDissolve;
        vc.menuVC = self
        
        self.present(vc, animated: true, completion: nil)
    }
    
    
    /*
    
     Loads values to menu counters
     
    */
    
    func setScreenCounters()
    {
        scorePointsLabel.text = String(sVarsShared.totalPointsScore)
        scoreKilometersLabel.text = String(format: "%.1f", sVarsShared.kilometersHighscore) + " km";
    }
    
    
    /*
    
     Shows daily bonus menu
     
    */
    
    func showDailyBonusScreenIfNeeded()
    {
        let now = Date.init()
        let calendar = Calendar.current
        
        let daynow = calendar.component(.day, from: now)
        let monthnow = calendar.component(.month, from: now)
        let daysaved = calendar.component(.day, from: sVarsShared.lastStartupDate!)
        let monthsaved = calendar.component(.month, from: sVarsShared.lastStartupDate!)
        
        if ( (daynow != daysaved || monthnow != monthsaved) )
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3)
            {
                let storyboard: UIStoryboard = UIStoryboard(name: "menu", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "bonusScreenVC") as! bonusScreenViewController
                
                vc.modalPresentationStyle = .overFullScreen;
                vc.modalTransitionStyle = .crossDissolve;
                //vc.menuVC = self
                
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        sVarsShared.lastStartupDate = now
    }
    
    
    /*
    
     On ad bonus button pressed
     
    */
    
    @IBAction func onAdBonusButtonPressed(sender : AnyObject)
    {
        let storyboard: UIStoryboard = UIStoryboard(name: "menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "bonusScreenVC") as! bonusScreenViewController
        
        vc.modalPresentationStyle = .overFullScreen;
        vc.modalTransitionStyle = .crossDissolve;
        vc.isDailyBonus = false
        //vc.menuVC = self
        
        self.present(vc, animated: true, completion: nil)
    }
    
    
    /*
    
    Play points-gaining animation
     
    */
    
    func playPointsGainingAnimation(_ pointsValue : UInt)
    {
        if pointsValue < 1 { return; }
        self.pointsGainView.translatesAutoresizingMaskIntoConstraints = false
        self.pointsGainView.alpha = 0
        self.pointsGainView.isHidden = false
        self.pointsGainViewString.text = "+ " + String(pointsValue)
        
        self.pointsGainView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        self.pointsGainView.layer.cornerRadius = 14;
        
        self.pointsGainView.center.x = self.view.center.x
        self.pointsGainView.center.y = self.view.center.y
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [],
                       animations: {
                        self.pointsGainView.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 2, delay: 0.5, options: [],
                       animations: {
                        self.pointsGainView.center.x = self.scoreContainer.center.x
                        self.pointsGainView.center.y = self.scoreContainer.center.y
        }, completion:
            {
                state in
                
                UIView.animate(withDuration: 0.5, delay: 0, options: [],
                               animations: {
                        self.pointsGainView.alpha = 0
                }, completion: {
                    state2 in
                    self.pointsGainView.isHidden = true
                })
            }
        )
    }
    
    
    /*
    
     Show points gaining animation if needed
     
    */
    
    func invokeGainigAnimationIfNeeded()
    {
        if(sharedDataStorage.pointsPending)
        {
            sharedDataStorage.pointsPending = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3))
            {
                self.playPointsGainingAnimation(sharedDataStorage.pointsToBeAnimated)
            }
        }
    }
    
}
