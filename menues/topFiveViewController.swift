//
//  topFiveViewController.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 20.07.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import UIKit

class topFiveViewController: UIViewController
{
    
    //DATA
    
    //subviews
    @IBOutlet var easySubview : UIView!
    @IBOutlet var mediumSubview : UIView!
    @IBOutlet var hardSubview : UIView!
    
    //name
    @IBOutlet var recName1_t0 : UILabel!
    @IBOutlet var recName2_t0 : UILabel!
    @IBOutlet var recName3_t0 : UILabel!

    @IBOutlet var recName1_t1 : UILabel!
    @IBOutlet var recName2_t1 : UILabel!
    @IBOutlet var recName3_t1 : UILabel!
    
    @IBOutlet var recName1_t2 : UILabel!
    @IBOutlet var recName2_t2 : UILabel!
    @IBOutlet var recName3_t2 : UILabel!
    
    //value
    @IBOutlet var recValue1_t0 : UILabel!
    @IBOutlet var recValue2_t0 : UILabel!
    @IBOutlet var recValue3_t0 : UILabel!

    @IBOutlet var recValue1_t1 : UILabel!
    @IBOutlet var recValue2_t1 : UILabel!
    @IBOutlet var recValue3_t1 : UILabel!
    
    @IBOutlet var recValue1_t2 : UILabel!
    @IBOutlet var recValue2_t2 : UILabel!
    @IBOutlet var recValue3_t2 : UILabel!
    
    //date
    @IBOutlet var recDate1_t0 : UILabel!
    @IBOutlet var recDate2_t0 : UILabel!
    @IBOutlet var recDate3_t0 : UILabel!
    
    @IBOutlet var recDate1_t1 : UILabel!
    @IBOutlet var recDate2_t1 : UILabel!
    @IBOutlet var recDate3_t1 : UILabel!
    
    @IBOutlet var recDate1_t2 : UILabel!
    @IBOutlet var recDate2_t2 : UILabel!
    @IBOutlet var recDate3_t2 : UILabel!
    
    override var prefersStatusBarHidden: Bool { return true; }
    private var highscoresManager = highScores()
    
    //METHODS
    
    /*
    
     Called after view is loaded
     
    */
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //BLUR
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ])
        
        
        //rounded corners
        easySubview.backgroundColor = UIColor.init(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.5)
        easySubview.layer.cornerRadius = 10;
        
        mediumSubview.backgroundColor = UIColor.init(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.5)
        mediumSubview.layer.cornerRadius = 10;
        
        hardSubview.backgroundColor = UIColor.init(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.5)
        hardSubview.layer.cornerRadius = 10;
        
        //content
        
        recName1_t0.text = "-----"; recValue1_t0.text = "--"; recDate1_t0.text = "--\n--";
        recName2_t0.text = "-----"; recValue2_t0.text = "--"; recDate2_t0.text = "--\n--";
        recName3_t0.text = "-----"; recValue3_t0.text = "--"; recDate3_t0.text = "--\n--";
        
        recName1_t1.text = "-----"; recValue1_t1.text = "--"; recDate1_t1.text = "--\n--";
        recName2_t1.text = "-----"; recValue2_t1.text = "--"; recDate2_t1.text = "--\n--";
        recName3_t1.text = "-----"; recValue3_t1.text = "--"; recDate3_t1.text = "--\n--";
        
        recName1_t2.text = "-----"; recValue1_t2.text = "--"; recDate1_t2.text = "--\n--";
        recName2_t2.text = "-----"; recValue2_t2.text = "--"; recDate2_t2.text = "--\n--";
        recName3_t2.text = "-----"; recValue3_t2.text = "--"; recDate3_t2.text = "--\n--";
        
        //content
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm\ndd.MM.yy";
        
        //easy
        
        let easyList = highscoresManager.getScoreObjectByType(0)
        
        if easyList.count > 0
        {
            recName1_t0.text = cutStringIfNeeded(easyList[0].name)
            recValue1_t0.text =  String(format: "%.1f", Double(easyList[0].value)) + " " + NSLocalizedString("REGIONAL_KILOMETERS", comment: "km");
            recDate1_t0.text = formatter.string(from: easyList[0].time)
        }
        
        if easyList.count > 1
        {
            recName2_t0.text = cutStringIfNeeded(easyList[1].name)
            recValue2_t0.text =  String(format: "%.1f", Double(easyList[1].value)) + " " + NSLocalizedString("REGIONAL_KILOMETERS", comment: "km");
            recDate2_t0.text = formatter.string(from: easyList[1].time)
        }
        
        if easyList.count > 2
        {
            recName3_t0.text = cutStringIfNeeded(easyList[2].name)
            recValue3_t0.text =  String(format: "%.1f", Double(easyList[2].value)) + " " + NSLocalizedString("REGIONAL_KILOMETERS", comment: "km");
            recDate3_t0.text = formatter.string(from: easyList[2].time)
        }
        
        //medium
        
        let mediumList = highscoresManager.getScoreObjectByType(1)
        
        if mediumList.count > 0
        {
            recName1_t1.text = cutStringIfNeeded(mediumList[0].name)
            recValue1_t1.text =  String(format: "%.1f", Double(mediumList[0].value)) + " " + NSLocalizedString("REGIONAL_KILOMETERS", comment: "km");
            recDate1_t1.text = formatter.string(from: mediumList[0].time)
        }
        
        if mediumList.count > 1
        {
            recName2_t1.text = cutStringIfNeeded(mediumList[1].name)
            recValue2_t1.text =  String(format: "%.1f", Double(mediumList[1].value)) + " " + NSLocalizedString("REGIONAL_KILOMETERS", comment: "km");
            recDate2_t1.text = formatter.string(from: mediumList[1].time)
        }
        
        if mediumList.count > 2
        {
            recName3_t1.text = cutStringIfNeeded(mediumList[2].name)
            recValue3_t1.text =  String(format: "%.1f", Double(mediumList[2].value)) + " " + NSLocalizedString("REGIONAL_KILOMETERS", comment: "km");
            recDate3_t1.text = formatter.string(from: mediumList[2].time)
        }
        
        //hard
        
        let hardList = highscoresManager.getScoreObjectByType(2)
        
        if hardList.count > 0
        {
            recName1_t2.text = cutStringIfNeeded(hardList[0].name)
            recValue1_t2.text =  String(format: "%.1f", Double(hardList[0].value)) + " " + NSLocalizedString("REGIONAL_KILOMETERS", comment: "km");
            recDate1_t2.text = formatter.string(from: hardList[0].time)
        }
        
        if hardList.count > 1
        {
            recName2_t2.text = cutStringIfNeeded(hardList[1].name)
            recValue2_t2.text =  String(format: "%.1f", Double(hardList[1].value)) + " " + NSLocalizedString("REGIONAL_KILOMETERS", comment: "km");
            recDate2_t2.text = formatter.string(from: hardList[1].time)
        }
        
        if hardList.count > 2
        {
            recName3_t2.text = cutStringIfNeeded(hardList[2].name)
            recValue3_t2.text =  String(format: "%.1f", Double(hardList[2].value)) + " " + NSLocalizedString("REGIONAL_KILOMETERS", comment: "km");
            recDate3_t2.text = formatter.string(from: hardList[2].time)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    /*
    
     Called when Return button pressed
     
    */
    
    @IBAction func onReturnButtonPressed(sender : AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
     
     Cuts string if needed
     
    */
    
    func cutStringIfNeeded(_ str : String) -> String
    {
        if(str.count > 14)
        {
            return String(str.prefix(13))+"...";
        }
        
        return str;
    }
}
