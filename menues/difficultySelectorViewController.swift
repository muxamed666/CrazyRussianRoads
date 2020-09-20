//
//  difficultySelectorViewController.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 24.09.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase


/*

 Level of difficulty selector
 
*/


class difficultySelectorViewController: UIViewController
{

    //DATA
    @IBOutlet var highlightSubview : UIView!
    @IBOutlet var fadeSubview : UIView!
    @IBOutlet var fadeSubviewBottomConstraint : NSLayoutConstraint!
    
    override var prefersStatusBarHidden: Bool { return true; }
    weak var menuVC : menuViewController!
    
    var player : AVAudioPlayer!
    
    //METHODS
    
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
        
        highlightSubview.backgroundColor = UIColor.init(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.5)
        highlightSubview.layer.cornerRadius = 10;
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
    
     Called when return button pressed
     
    */
    
    @IBAction func onReturnButtonPressed(sender : AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
    
     Sound player
     
    */
    
    func playSound()
    {
        guard let parental = self.presentingViewController as? menuViewController
            else { return; }
        
        parental.stopBackgroundMusic()
        
        if(sVarsShared.soundEnabled)
        {
            guard let path = Bundle.main.path(forResource: "GM_b15d2", ofType: "mp3")else{return}
            let soundURl = URL(fileURLWithPath: path)
            player = try? AVAudioPlayer(contentsOf: soundURl)
            if (player != nil)
            {
                player.prepareToPlay()
                player.volume = 0.3;
                player.play()
            }
        }
    }
    

    
    /*
    
     Called when easy level of difficulty selected
     
    */
    
    @IBAction func easyLevelButton(sender : AnyObject)
    {
        fadeSubviewBottomConstraint.constant = 0;
        playSound()
        
        Analytics.logEvent("difficulty_selected", parameters: ["value" : "easy"])
        
        UIView.animate(withDuration: 2.7, animations: {
            self.fadeSubview.alpha = 1;
        }, completion: {
            state in
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "gameController") as! GameViewController
            
            self.menuVC.menuBlackFadeRect.isHidden = false;
            vc.difficultyLevel = 1;
            
            self.dismiss(animated: false, completion: {
                self.menuVC.present(vc, animated: false, completion: nil)
            })
            
        })
    }
    
    
    /*
     
     Called when middle level of difficulty selected
     
    */
    
    @IBAction func middleLevelButton(sender : AnyObject)
    {
        fadeSubviewBottomConstraint.constant = 0;
        playSound()
        
        Analytics.logEvent("difficulty_selected", parameters: ["value" : "middle"])
        
        UIView.animate(withDuration: 2.7, animations: {
            self.fadeSubview.alpha = 1;
        }, completion: {
            state in
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "gameController") as! GameViewController
            
            self.menuVC.menuBlackFadeRect.isHidden = false;
            vc.difficultyLevel = 2;
            
            self.dismiss(animated: false, completion: {
                self.menuVC.present(vc, animated: false, completion: nil)
            })
            
        })
    }
    
    
    /*
     
     Called when hard level of difficulty selected
     
    */
    
    @IBAction func hardLevelButton(sender : AnyObject)
    {
        fadeSubviewBottomConstraint.constant = 0;
        playSound()
        
        Analytics.logEvent("difficulty_selected", parameters: ["value" : "hard"])
        
        UIView.animate(withDuration: 2.7, animations: {
            self.fadeSubview.alpha = 1;
        }, completion: {
            state in
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "gameController") as! GameViewController
            
            self.menuVC.menuBlackFadeRect.isHidden = false;
            vc.difficultyLevel = 3;
            
            self.dismiss(animated: false, completion: {
                self.menuVC.present(vc, animated: false, completion: nil)
            })
            
        })
    }
}
