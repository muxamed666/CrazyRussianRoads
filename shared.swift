//
//  shared.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 02.02.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import Foundation
import SpriteKit
import AudioToolbox


/*
 
 Class stores applicationwide data
 
*/

class sharedData
{
    //weak var will become nil if object is deallocated by GC
    //so, it is needed to allways perform a nil-check
    weak var gameSceneLink : GameScene?
    var isInDebugMode : Bool = false
    var gdprAskNeeded : Bool = false
    var gdprReaskAvailiable : Bool = false
    
    var pointsPending : Bool = false
    var pointsToBeAnimated : UInt = 0
}


/*

 Class stores applicationwide methods
 
*/

class sharedMethods
{
    /*
     
     Forces iPhone to make vibration sound
     Disabled on iPad (userInterfaceIdiom == .pad)
     Taptic Engine disabled for 5/5S/SE compat.
     
     */
    
    func makeBzzzzByVibrator()
    {
        if(sVarsShared.vibroEnabled)
        {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    
    /*
     
     Shows simple messageobx
     
    */
    
    func showMessageBox(title : String, message : String, vc : UIViewController)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        
        //sync back into main thread
        //to avoid datarace bug and crash
        DispatchQueue.main.async
        {
            vc.present(alertController, animated: true)
        }
    }
    
    
    /*
     
     Shows alert controller with hurtable option (red)
     Gives control to hander function selected depending on a user choise
     
    */
    
    func hurtableActionMessageBox(message : String,
                                  normalOption : String, hurtableOption : String,
                                  normalOptionHandler : @escaping () -> Void, hurtableOptionHandler : @escaping () -> Void,
                                  vc : UIViewController)
    {
        //controller to provide this alert box behaviours
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        //okay here, we actually add an UIAlertAction, that have lambda handler, that calls out closure
        //we mark function (doesent matter is it in closure or just passed as argument) as @escaping
        //because it can be called later as callback. Swift uses @noescape by default
        let cancelAction = UIAlertAction(title: normalOption, style: .default, handler : { _ in normalOptionHandler() })
        alertController.addAction(cancelAction)
        
        //same with destructive option
        let destroyAction = UIAlertAction(title: hurtableOption, style: .destructive, handler: { _ in hurtableOptionHandler() })
        alertController.addAction(destroyAction)
        
        //popover settings for an ipads
        if let popoverPresentationController = alertController.popoverPresentationController
        {
            popoverPresentationController.sourceView = vc.view
            popoverPresentationController.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        
        //sync back into main thread
        //to avoid datarace bug and crash
        DispatchQueue.main.async
        {
            vc.present(alertController, animated: true)
        }
    }
    
}


var sharedDataStorage = sharedData()
var sharedMethodsStorage = sharedMethods()
