//
//  rewardedAdViewController.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 20.01.2020.
//  Copyright © 2020 Muxa Mot. All rights reserved.
//

import UIKit
import Foundation
import GoogleMobileAds
import Firebase

class rewardedAdViewController: UIViewController, GADRewardedAdDelegate
{

    //DATA
    @IBOutlet var exitButton : UIButton!
    
    override var prefersStatusBarHidden: Bool { return true; }
    var rewarded : GADRewardedAd!
    var menuVC : menuViewController!
    var bonusVC : bonusScreenViewController!
    var completionHandler: (()->Void)?
    
    
    //METHODS
    override func viewDidLoad()
    {
        super.viewDidLoad()

        rewarded = sharedAdsManager.rewardedAd
        
        if (rewarded == nil) { return; }
        
        GADMobileAds.sharedInstance().applicationMuted = !sVarsShared.soundEnabled
        GADMobileAds.sharedInstance().applicationVolume = 0.4
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1))
        {
            if (self.rewarded.isReady)
            {
                self.rewarded.present(fromRootViewController: self, delegate: self)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if (rewarded == nil) { return; }
        
        exitButton.alpha = 0
        
        UIView.animate(withDuration: 1, delay: 6, options: [], animations:
            {
                self.exitButton.alpha = 1
        }, completion: nil)
        
        if(sVarsShared.soundEnabled) { menuVC.setBackgroundMusicVolume(0) }
    }
    

    // Tells the delegate that the user earned a reward.
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward)
    {
        print("Reward received! 30 points.")
        Analytics.logEvent(AnalyticsEventEarnVirtualCurrency, parameters: [ "virtual_currency_name" : "Points", "value" : 30])
        sVarsShared.totalPointsScore = sVarsShared.totalPointsScore + 30;
        bonusVC.pointsWasGained = true
        menuVC.setScreenCounters()
    }
    
    // Tells the delegate that the rewarded ad was presented.
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd)
    {
        print("Rewarded ad presented.")
    }
    
    // Tells the delegate that the rewarded ad was dismissed.
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd)
    {
        print("Rewarded ad dismissed.")
        sharedAdsManager.createAndLoadRewardedAd()
        if(sVarsShared.soundEnabled) { menuVC.setBackgroundMusicVolume(0.2) }
        self.dismiss(animated: true, completion: completionHandler)
    }
    
    // Tells the delegate that the rewarded ad failed to present.
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error)
    {
        print("Rewarded ad failed to present.")
        sharedAdsManager.createAndLoadRewardedAd()
        if(sVarsShared.soundEnabled) { menuVC.setBackgroundMusicVolume(0.2) }
        self.dismiss(animated: true, completion: completionHandler)
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onExitButton()
    {
        sharedAdsManager.createAndLoadRewardedAd()
        if(sVarsShared.soundEnabled) { menuVC.setBackgroundMusicVolume(0.2) }
        self.dismiss(animated: true, completion: completionHandler)
    }
    
}
