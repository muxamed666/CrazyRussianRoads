//
//  ads.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 05.12.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import Foundation
import GoogleMobileAds


/*
 
 Class for advertisement management, loads ads in background
 
*/

class AdsManager
{
    //DATA
    
    //test block ids
    //TODO: change to actual block ids on release
    let interstitialAdId : String = "ca-app-pub-"
    
    let rewardedAdId : String = "ca-app-pub-"
    
    //Ad objects
    var interstitialAd : GADInterstitial!
    var rewardedAd : GADRewardedAd!
    
    //<Google> To get test ads on this device, set: GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ @"" ];
    
    
    
    //METHODS
    
    /*
    
     Creates new intersitial ad and load it from Google AdMob
     
    */
    
    func createAndLoadIntersitialAd()
    {
        print("Revalidating intersitial Ad")
        
        let interstitial = GADInterstitial(adUnitID: self.interstitialAdId)
        interstitial.load(GADRequest())
        self.interstitialAd = interstitial
    }
    
    /*
     
     Creates new rewarded ad and load it from Google AdMob
     
     */
    
    func createAndLoadRewardedAd()
    {
        print("Revalidating rewarded Ad")
        
        let rewarded = GADRewardedAd(adUnitID: self.rewardedAdId)
        rewarded.load(GADRequest())
        self.rewardedAd = rewarded
    }
}

var sharedAdsManager : AdsManager = AdsManager()
