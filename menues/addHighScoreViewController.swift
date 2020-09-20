//
//  addHighScoreViewController.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 07.07.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import UIKit
import Firebase

class addHighScoreViewController: UIViewController, UITextFieldDelegate
{

    @IBOutlet var kilometresLabel : UILabel?
    @IBOutlet var nameTextField : UITextField?
    @IBOutlet var highlightSubview : UIView?
    
    var kilometersInRecord : Float = -1;    //kilometres to be recorded
    weak var scoresManager : highScores?    //weak to prevent memory leakage
    var fromDefeatScreen : Bool = false     //parent type
    weak var defeatVC : defeatScreenViewController?
    weak var pauseVC : pauseScreenViewController?
    
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
        
        //gray subview
        highlightSubview!.backgroundColor = UIColor.init(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.5)
        highlightSubview!.layer.cornerRadius = 10;
        
        //make keyboard hide
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        //became a textfields delegate
        nameTextField!.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        Analytics.logEvent("add_score_request", parameters: [:])
        
        //updates
        kilometresLabel?.text = String(format: "%.2f", Double(kilometersInRecord)) + " " + NSLocalizedString("REGIONAL_KILOMETERS", comment: "km");
    }
    
    override var prefersStatusBarHidden: Bool { return true; }


    /*
    
     Function called when user taps anywhere in the screen. Hides keyboard.
     
    */
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    
    /*
    
     Function called on "SAVE" button pressed
     
    */
    
    @IBAction func onSaveButtonPressed(sender: AnyObject)
    {
        let gameType = sharedDataStorage.gameSceneLink!.highScoresGameType
        
        guard var recName : String = nameTextField!.text
            else {
                sharedMethodsStorage.showMessageBox(title:
                    NSLocalizedString("HSVC_NAMEERROR_TILE", comment: "title"),
                    message: NSLocalizedString("HSVC_NAMEERROR_BODY", comment: "body"),
                    vc: self)
                return;
        }
        
        if (recName.count > 30)
        {
            sharedMethodsStorage.showMessageBox(title:
                NSLocalizedString("HSVC_NAMEERROR_TILE", comment: "title"),
                message: NSLocalizedString("HSVC_NAMEERROR_BODY", comment: "body"),
                vc: self)
            return;
        }
        
        //some escaping
        recName = recName.replacingOccurrences(of: "\\", with: " ")
        recName = recName.replacingOccurrences(of: "/", with: " ")
        recName = recName.replacingOccurrences(of: "\"", with: " ")
        recName = recName.replacingOccurrences(of: "'", with: " ")
        recName = recName.replacingOccurrences(of: "#", with: " ")
        recName = recName.replacingOccurrences(of: ",", with: " ")
        recName = recName.replacingOccurrences(of: ".", with: " ")
        
        if (recName.count == 0)
        {
            recName = NSLocalizedString("HSVC_NONAME", comment: "No Name");
        }
        
        /*
        //name check
        if(!scoresManager!.checkUniqueName(name: recName, type: gameType))
        {
            sharedMethodsStorage.showMessageBox(title:
                NSLocalizedString("HSVC_NAMEERROR_TILE", comment: "title"),
                message: NSLocalizedString("HSVC_NAMEERROR_EXISTS", comment: "exists"),
                vc: self)
            return;
        }
        */
        
        //save'n'exit
        if(scoresManager!.checkHighScore(kms: kilometersInRecord, type: gameType))
        {
            scoresManager!.instertHighScore(name: recName, kms: kilometersInRecord, type: gameType)
            
            Analytics.logEvent(AnalyticsEventPostScore, parameters: [ "score" : kilometersInRecord ])
            
            //get blank VC on background
            if(self.fromDefeatScreen)
            {
                self.defeatVC!.goBlank()
            }
            else
            {
                self.pauseVC!.goBlank()
            }
            
            //exit
            self.dismiss(animated: true, completion: {
                if(self.fromDefeatScreen)
                {
                    self.defeatVC!.gracefullyDismiss()
                }
                else
                {
                    self.pauseVC!.gracefullyDismiss()
                }
            })
            
            return;
        }
    }
    
    
    /*
    
     On keyboards return button
     
    */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
    
    
    /*
    
     Called when cancel button tapped
     
    */
    
    @IBAction func onCancelButtonTapped(sender : AnyObject)
    {
        //get blank VC on background
        if(self.fromDefeatScreen)
        {
            self.defeatVC!.goBlank()
        }
        else
        {
            self.pauseVC!.goBlank()
        }
        
        Analytics.logEvent("post_score_denied", parameters: [:])
        
        //exit
        self.dismiss(animated: true, completion: {
            if(self.fromDefeatScreen)
            {
                self.defeatVC!.gracefullyDismiss()
            }
            else
            {
                self.pauseVC!.gracefullyDismiss()
            }
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
