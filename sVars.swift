//
//  sVars.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 23.02.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import Foundation


/*

 Stores settings, records, and unlockable content
 Saves it to device and restores on init (TODO)
 
*/

class sVars
{

    // DATA //
    
    private static let sVarsProtocolVersion : Int = 2
    private var svarsFilePath : String!
    private var svarsFileURL : URL?
    private var values = sVarsValues()
    
    
    // SUBSTRUCTS //
    
    
    /*
     
     Serializable (codable) structure contains object for high score record
     
    */
    
    struct highScoreObject : Codable
    {
        var name : String = ""
        var value : Float = 0
        var time : Date = Date.init(timeIntervalSinceNow: 0)
    }
    
    
    /*
     
     Serializable (codable) structure contains data mask for JSON serialization
     
    */
    
    struct sVarsValues : Codable
    {
        var structVersion : Int = sVarsProtocolVersion
        var soundEnabled : Bool = true
        var vibroEnabled : Bool = true
        var totalPointsScore : UInt = 0
        var kilometersHighscore : Float = 0
        var availableCarsIds : [Int] = [1]
        var availableRoadsIds : [Int] = []
        
        //Do not ignore optionals from here, they can be nil =(
        //IMPORTANT: add new properties to sVars protocol only as optionals
        //IMPORTANT: update "resetOptionals" func after adding
        var currentCarId : Int? = 1
        var firstStartup : Bool? = true
        var lastStartupDate : Date? = Date(timeIntervalSince1970: 1577836800)
        
        var highScoresListEasy : [highScoreObject]? = []
        var highScoresListMedium : [highScoreObject]? = []
        var highScoresListHard : [highScoreObject]? = []
    }
    
    
    // ACCESSORS //
    
    //sound
    var soundEnabled : Bool {
        get { return values.soundEnabled }
        set (val) { values.soundEnabled = val; self.rewrite(); }
    }
    
    //vibro
    var vibroEnabled : Bool {
        get { return values.vibroEnabled }
        set (val) { values.vibroEnabled = val; self.rewrite(); }
    }
    
    //total points score (wallet)
    var totalPointsScore : UInt {
        get { return values.totalPointsScore }
        set (val) { values.totalPointsScore = val; self.rewrite(); }
    }
    
    //kilometers (high score)
    var kilometersHighscore : Float {
        get { return values.kilometersHighscore }
        set (val) { values.kilometersHighscore = val; self.rewrite(); }
    }
    
    //available cars id array
    var availableCarsIds : [Int] {
        get { return values.availableCarsIds }
        set (val) { values.availableCarsIds = val; self.rewrite(); }
    }
    
    //available roads id array
    var availableRoadsIds : [Int] {
        get { return values.availableRoadsIds }
        set (val) { values.availableRoadsIds = val; self.rewrite(); }
    }
    
    //current car id
    var currentCarId : Int? {
        get { return values.currentCarId }
        set (val) { values.currentCarId = val; self.rewrite(); }
    }
    
    //first startup marker
    var firstStartup : Bool? {
        get { return values.firstStartup }
        set (val) { values.firstStartup = val; self.rewrite(); }
    }
    
    //date of last startup for daily bonus
    var lastStartupDate : Date? {
        get { return values.lastStartupDate }
        set (val) { values.lastStartupDate = val; self.rewrite(); }
    }
    
    //high score for easy mode
    var highScoresListEasy : [highScoreObject]? {
        get { return values.highScoresListEasy }
        set (val) { values.highScoresListEasy = val; self.rewrite(); }
    }
    
    //high score for medium mode
    var highScoresListMedium : [highScoreObject]? {
        get { return values.highScoresListMedium }
        set (val) { values.highScoresListMedium = val; self.rewrite(); }
    }
    
    //high score for hard mode
    var highScoresListHard : [highScoreObject]? {
        get { return values.highScoresListHard }
        set (val) { values.highScoresListHard = val; self.rewrite(); }
    }
    
    
    // METHODS //
    
    /*
     
     Restores vars from device fs, inits with defaults if not found (TODO)
     
    */
    
    init()
    {
        let res = loadOrCreate()
        if (res == false) { fatalError("Failed to read/write to filesystem!") }
    }
    
    
    /*
    
     Saves itself to disk before death
     
    */
    
    deinit
    {
        self.rewrite();
    }
    
    
    /*
    
     Working with device FS
     
    */
    
    func loadOrCreate() -> Bool
    {
        // Move svars file from bundle to documents dir
        // filemanager used to access apps documents directory
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        //Check if documents dir availible
        guard documentsUrl.count != 0 else
        {
            NSLog("Documents error!")
            return false; // Could not find documents URL
        }
        
        // Path where svars file placed on end user device
        let finalSvarsURL = documentsUrl.first!.appendingPathComponent("crr-data.json")
        
        //check if file already exists
        if !((try? finalSvarsURL.checkResourceIsReachable()) ?? false)
        {
            NSLog("DB does not exist in documents folder")
            
            //set path & URL
            svarsFilePath = finalSvarsURL.path;
            svarsFileURL = finalSvarsURL;
            
            //file not found, try to create new one with defaults
            values = sVarsValues()
            let encoder = JSONEncoder()
            
            //encode and save
            do
            {
                let jsontext = try encoder.encode(values)
                try jsontext.write(to: finalSvarsURL)
            }
            catch let error
            {
                print(error)
                return false;
            }
            
            return true;
        }
        else
        {
            //file found, load it
            NSLog("Svars file found at path: \(finalSvarsURL.path)")
            svarsFilePath = finalSvarsURL.path;
            svarsFileURL = finalSvarsURL
            
            do
            {
                var jsontext : String
                let decoder = JSONDecoder()
                jsontext = try String.init(contentsOfFile: svarsFilePath)
                values = try decoder.decode(sVarsValues.self, from: jsontext.data(using: .utf8)!)
            }
            catch let error
            {
                print(error)
                return false;
            }
            
            resetOptionals();
            
            return true;
        }
    }
    
 
    /*
    
     Rewrites settings and records on local device
     
    */
    
    func rewrite()
    {
        //encode and save
        do
        {
            let encoder = JSONEncoder()
            let jsontext = try encoder.encode(values)
            try jsontext.write(to: self.svarsFileURL!)
        }
        catch let error
        {
            print(error)
        }
    }
    
    
    /*
    
     Reset optionals
     
    */
    
    func resetOptionals()
    {
        if values.currentCarId == nil { values.currentCarId = 1 }
        if values.firstStartup == nil { values.firstStartup = true }
        if values.lastStartupDate == nil { values.lastStartupDate = Date(timeIntervalSince1970: 1577836800) }
        if values.highScoresListEasy == nil { values.highScoresListEasy = [] }
        if values.highScoresListMedium == nil { values.highScoresListMedium = [] }
        if values.highScoresListHard == nil { values.highScoresListHard = [] }
    }
    
    
    /*
    
     Drop to defaults
     
    */
    
    func dropAllDataToDefaults()
    {
        values = sVarsValues()
        rewrite()
    }
}

var sVarsShared = sVars()
