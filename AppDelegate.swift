//
//  AppDelegate.swift
//  Crazy Russian Road
//
//  Created by Muxa Mot on 05.09.2018.
//  Copyright © 2018 Muxa Mot. All rights reserved.
//

import UIKit
import GoogleMobileAds
import PersonalizedAdConsent
import AdSupport
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        
        /*
        //debug
        NSLog("Advertising ID: %@", ASIdentifierManager.shared().advertisingIdentifier.uuidString);
        PACConsentInformation.sharedInstance.debugIdentifiers = [""];
        PACConsentInformation.sharedInstance.debugGeography = .notEEA;
        */
        
        //GDPR consent!!!
    
        PACConsentInformation.sharedInstance.requestConsentInfoUpdate(
            forPublisherIdentifiers: [""])
        {(_ error: Error?) -> Void in
            if let error = error {
                print("GDPR: Consent info update failed. ")
                print(error)
            } else {
                // Consent info update succeeded. The shared PACConsentInformation
                // instance has been updated.
                print("GDPR: Consent info update succeeded. ")
                
                if (PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown)
                {
                    let status = PACConsentInformation.sharedInstance.consentStatus
                    sharedDataStorage.gdprReaskAvailiable = true //reask feature in app settings
                    
                    if (status == PACConsentStatus.personalized || status == PACConsentStatus.nonPersonalized)
                    {
                        //already asked
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
                    else
                    {
                        //ask
                        sharedDataStorage.gdprAskNeeded = true
                    }
                }
                else
                {
                    print("Not in EU, EEA skipping GDPR consent")
                    sharedDataStorage.gdprReaskAvailiable = false //reask feature in app settings
                    
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

        
        
        //Google Firebase Init
        FirebaseApp.configure()
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
        //TODO: force save scores/settings
        
        //return if current scene dead
        guard let gameSceneObj = sharedDataStorage.gameSceneLink else { return; }
        
        gameSceneObj.gamePaused = true;
        gameSceneObj.scene?.isPaused = true;
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //force save scores
        //force save scores/settings if game is running
        if let gameSceneObj = sharedDataStorage.gameSceneLink
        {
            if (Float(gameSceneObj.kilometers) > sVarsShared.kilometersHighscore)
            {
                sVarsShared.kilometersHighscore = Float(gameSceneObj.kilometers)
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        guard let gameSceneObj = sharedDataStorage.gameSceneLink else
        {
            //NSLog("Scene is null!")
            return
        }

        if gameSceneObj.whitescreenTimerIsActive
        {
            //print("Unpausing due to whitescreen timer")
            gameSceneObj.gamePaused = false
            gameSceneObj.scene?.isPaused = false
            return
        }
        
        gameSceneObj.showPauseScreenIfNeeded()
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate.
        // See also applicationDidEnterBackground:.
        
        //force save scores/settings if game is running
        if let gameSceneObj = sharedDataStorage.gameSceneLink
        {
            sVarsShared.totalPointsScore = sVarsShared.totalPointsScore + UInt(gameSceneObj.points);
            if (Float(gameSceneObj.kilometers) > sVarsShared.kilometersHighscore)
            {
                sVarsShared.kilometersHighscore = Float(gameSceneObj.kilometers)
            }
            
            Analytics.logEvent(AnalyticsEventEarnVirtualCurrency, parameters: [ "virtual_currency_name" : "Points", "value" : gameSceneObj.points])
            
            Analytics.logEvent("appTerminate", parameters: [ "game_session" : "running" ])
        }
        else
        {
            Analytics.logEvent("appTerminate", parameters: [ "game_session" : "not_running" ])
        }
    }


}

