//
//  settingsScreenViewController.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 02.03.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import UIKit
import SafariServices
import PersonalizedAdConsent
import GoogleMobileAds

class settingsScreenViewController: UIViewController
{
    //DATA
    @IBOutlet var toggleSoundButton : UIButton!
    @IBOutlet var toggleVibroButton : UIButton!
    @IBOutlet var gdprReaskButton : UIButton!
    
    override var prefersStatusBarHidden: Bool { return true; }
    
    
    //METHODS
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
        
        if(sharedDataStorage.gdprReaskAvailiable)
        {
            gdprReaskButton.isHidden = false
            gdprReaskButton.isEnabled = true
        }
        else
        {
            gdprReaskButton.isHidden = true
            gdprReaskButton.isEnabled = false
        }
        
        // Do any additional setup after loading the view.
        
        //BLUR
        view.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ])
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
    
    
    /*
    
     Called when user press return button
     
    */
    
    @IBAction func onReturnButtonPressed()
    {
        guard let parental = self.presentingViewController as? menuViewController
            else { return; }
        
        parental.setScreenCounters()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
     
     Called when user taps sound button
     
    */
    
    @IBAction func toggleSoundButtonPressed()
    {
        sVarsShared.soundEnabled = !sVarsShared.soundEnabled;
        if(sVarsShared.soundEnabled)
        {
            toggleSoundButton.setImage(#imageLiteral(resourceName: "menuSoundEnabled"), for: .normal)
            guard let parental = self.presentingViewController as? menuViewController
                else { return; }
            parental.setBackgroundMusicVolume(0.2)
        }
        else
        {
            toggleSoundButton.setImage(#imageLiteral(resourceName: "menuSoundDisabled"), for: .normal)
            guard let parental = self.presentingViewController as? menuViewController
                else { return; }
            parental.setBackgroundMusicVolume(0)
        }
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
    
     Called when user taps reset game records
     
    */
    
    @IBAction func resetRecordsButtonPressed()
    {
        sharedMethodsStorage.hurtableActionMessageBox(
            message: NSLocalizedString("STVC_RECORDS", comment: "records to be deleted"),
            normalOption: NSLocalizedString("STVC_CANCEL", comment: "cancel"),
            hurtableOption: NSLocalizedString("STVC_RESET", comment: "reset"),
            normalOptionHandler: { /* do nothing */ },
            hurtableOptionHandler:
                {
                    sVarsShared.kilometersHighscore = 0;
                    sVarsShared.highScoresListEasy?.removeAll()
                    sVarsShared.highScoresListMedium?.removeAll()
                    sVarsShared.highScoresListHard?.removeAll()
                },
            vc: self)
    }
    
    
    /*
    
     Called when user taps reset all game
     
    */
    
    @IBAction func resetGameButtonPressed()
    {
        sharedMethodsStorage.hurtableActionMessageBox(
            message: NSLocalizedString("STVC_GAMEFILE", comment: "records to be deleted"),
            normalOption: NSLocalizedString("STVC_CANCEL", comment: "cancel"),
            hurtableOption: NSLocalizedString("STVC_RESET", comment: "reset"),
            normalOptionHandler: { /* do nothing */ },
            hurtableOptionHandler:
                {
                    sVarsShared.dropAllDataToDefaults()
                },
            vc: self)
    }
    
    
    /*
     
     Called when user taps enter debug mode button (Deprecated since 0.3 RC)
     
    */
    /*
    @IBAction func toggleDebugModeButtonPressed()
    {
        sharedDataStorage.isInDebugMode = !sharedDataStorage.isInDebugMode
        
        //debug debug debug
        sVarsShared.totalPointsScore += 999;
        
        sharedMethodsStorage.showMessageBox(title: "Debug Mode", message: "Debug Mode Enabled = " + String(sharedDataStorage.isInDebugMode), vc: self)
    }
     
    */
    
    
    /*
    
     Redirect user to game website using in-app Safari View Controller
     
    */
    
    @IBAction func toWebsite(sender : AnyObject)
    {
        //http://mihail.motylenok.com/crr-game/
        guard let url = URL(string: "http://crr-game.motylenok.com/") else { return }
        
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    
    /*
    
     Update user consent status (EU and EEA regions only)
     
    */
    
    @IBAction func changeOrRevokeGDPRConsent(sender : AnyObject)
    {
        if(sharedDataStorage.gdprReaskAvailiable)
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
                            //no google reinit, because google admob is alread initialized
                        }
                    }
                    
                }
            }
            
        }
        else
        {
            sharedMethodsStorage.showMessageBox(title: "EEA Personalized Ads Consent", message: "Personalized Ads Options is only for EU and EEA users.", vc: self)
        }
    }
}
