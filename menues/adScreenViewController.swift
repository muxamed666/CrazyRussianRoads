//
//  adScreenViewController.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 05.12.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import UIKit
import Foundation
import GoogleMobileAds

class adScreenViewController: UIViewController, GADInterstitialDelegate
{
    //DATA
    @IBOutlet var funnyLabel : UILabel!
    @IBOutlet var stuckExitButton : UIButton!
    
    var interstitial : GADInterstitial!
    var completionHandler: (()->Void)?
    var presented : Bool = false
    
    override var prefersStatusBarHidden: Bool { return true; }
    
    
    //METHODS
    
    /*
    
     Called when view is loaded
     
    */
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        interstitial = sharedAdsManager.interstitialAd
        
        if (interstitial == nil) { return; }
        
        interstitial.delegate = self
        
        GADMobileAds.sharedInstance().applicationMuted = !sVarsShared.soundEnabled
        GADMobileAds.sharedInstance().applicationVolume = 0.4
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2))
        {
            //it is assumed that "not used" and "loaded" checks are already done!!
            self.interstitial.present(fromRootViewController: self)
        }
    }
    
    
    /*
    
     Called when view is ready to appear
     
    */

    override func viewWillAppear(_ animated: Bool)
    {
        funnyLabel.alpha = 0
        stuckExitButton.alpha = 0
        
        if (!presented)
        {
            UIView.animate(withDuration: 2, delay: 0, options: [], animations:
                {
                    self.funnyLabel.alpha = 1
                }, completion: nil)
            presented = true
        }
        
        UIView.animate(withDuration: 1, delay: 6, options: [], animations:
            {
                self.stuckExitButton.alpha = 1
        }, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError)
    {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    // Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial)
    {
        print("interstitialWillPresentScreen")
    }
    
    
    // Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial)
    {
        print("interstitialDidDismissScreen")
        self.dismiss(animated: false, completion: completionHandler)
    }
    
    // Tells the delegate that a user click will open another app
    // (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial)
    {
        print("interstitialWillLeaveApplication")
    }


    
    //if user stuck on this screen for some reason
    @IBAction func stuckExit(sender : AnyObject)
    {
        self.dismiss(animated: false, completion: completionHandler)
    }
}
