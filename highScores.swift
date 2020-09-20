//
//  highScores.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 01.07.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


/*

 This class is for handling high score list
 
*/

class highScores
{
    /*
    
     Returns temprary score object by given type
     
    */
    
    func getScoreObjectByType(_ type : Int) -> [sVars.highScoreObject]
    {
        switch type
        {
        case 0:
            return sVarsShared.highScoresListEasy!
        case 1:
            return sVarsShared.highScoresListMedium!
        case 2:
            return sVarsShared.highScoresListHard!
        default:
            return sVarsShared.highScoresListEasy!
        }
    }
    
    
    /*
     
     Returns temprary score object by given type
     
    */
    
    func setScoreObjectByType(type : Int, obj : [sVars.highScoreObject])
    {
        switch type
        {
        case 0:
            sVarsShared.highScoresListEasy = obj
            return
        case 1:
            sVarsShared.highScoresListMedium = obj
            return
        case 2:
            sVarsShared.highScoresListHard = obj
            return
        default:
            sVarsShared.highScoresListEasy = obj
        }
    }
    
    
    /*
    
     Return true if highscore will appear in list of highscores
     
    */
    
    //Types:
    // 0 - easy
    // 1 - medium
    // 2 - hard
    
    func checkHighScore(kms : Float, type : Int) -> Bool
    {
        let tmpHSList : [sVars.highScoreObject] = getScoreObjectByType(type)
        
        if tmpHSList.count < 3
        {
            return true;
        }
        else
        {
            if(kms > tmpHSList[2].value)
            {
                return true
            }
            else
            {
                return false
            }
        }
    }
    
    
    /*
    
     Check name for uniqueness
     True if unique
     
    */
    
    func checkUniqueName(name : String, type : Int) -> Bool
    {
        let tmpHSList = getScoreObjectByType(type)
        
        for score in tmpHSList
        {
            if(score.name == name)
            {
                return false;
            }
        }

        return true;
    }
    
    
    /*
    
     Inserts new highscore in the dictionary
     It is assumed that checkHighScore is called before
     and name check is performed!
     
    */
    
    func instertHighScore(name : String, kms : Float, type : Int)
    {
        var newHS = sVars.highScoreObject()
        newHS.name = name
        newHS.value = kms
        newHS.time = Date.init(timeIntervalSinceNow: 0)
        
        //insert new in list
        var list = getScoreObjectByType(type)
        list.append(newHS)
        
        //sort
        list.sort(by: { $0.value > $1.value })
        
        //delete last
        while list.count > 3
        {
            list.removeLast()
        }
        
        //replace list on a disk
        setScoreObjectByType(type: type, obj: list)
        sVarsShared.rewrite()
    }
    
}
