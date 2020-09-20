//
//  bonusScreenViewController.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 18.01.2020.
//  Copyright © 2020 Muxa Mot. All rights reserved.
//

import UIKit
import Firebase

class bonusScreenViewController: UIViewController
{
    //DATA
    @IBOutlet var highlightSubview : UIView!
    @IBOutlet var messageString : UILabel!
    @IBOutlet var actionButton : UIButton!
    @IBOutlet var bonusImage : UIImageView!
    @IBOutlet var closeButton : UIButton!
    
    var isDailyBonus : Bool = true
    var pointsWasGained : Bool = false
    
    //METHODS
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //BLUR
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        //blurView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ])
        
        highlightSubview.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 1)
        highlightSubview.layer.cornerRadius = 10;
        
        if isDailyBonus
        {
            closeButton.alpha = 0
            closeButton.isHidden = true
        }
        else
        {
            switchToAdBonusMode()
        }
    }
    

    /*
    
     Action!
     
    */
    
    @IBAction func onActionButtonPressed()
    {
        if(isDailyBonus)
        {
            sVarsShared.totalPointsScore = sVarsShared.totalPointsScore + 30
            
            pointsWasGained = true
            
            Analytics.logEvent("daily_bonus", parameters: [:])
            Analytics.logEvent(AnalyticsEventEarnVirtualCurrency, parameters: [ "virtual_currency_name" : "Points", "value" : 30])
            
            guard let parental = self.presentingViewController as? menuViewController
                else { return; }
            
            parental.setScreenCounters()
            
            self.dismiss(animated: true, completion: { if (self.pointsWasGained) { parental.playPointsGainingAnimation(30) } })
        }
        else
        {
            
            if(sharedAdsManager.rewardedAd.isReady)
            {
                let storyboard: UIStoryboard = UIStoryboard(name: "menu", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "rewScreenVC") as! rewardedAdViewController
                
                guard let parental = self.presentingViewController as? menuViewController
                    else { return; }
                
                vc.modalPresentationStyle = .overFullScreen;
                vc.modalTransitionStyle = .crossDissolve;
                vc.menuVC = parental
                vc.bonusVC = self
                vc.completionHandler = { self.dismiss(animated: true, completion: { if (self.pointsWasGained) { parental.playPointsGainingAnimation(30) } }); }
                
                Analytics.logEvent("ad_view_bonus", parameters: [:])
                
                self.present(vc, animated: true, completion: nil)
                return;
            }
            else
            {
                sharedMethodsStorage.showMessageBox(title: NSLocalizedString("ABVC_ERROR_TITLE", comment: "message"), message: NSLocalizedString("ABVC_ERROR", comment: "message"), vc: self)
            }
            
        }
    }
    
    
    /*
    
     Close
     
    */
    
    @IBAction func onCloseButtonPressed()
    {
        self.dismiss(animated: true, completion: nil)
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
     
    Switch view to ad bonus mode
     
    */

    func switchToAdBonusMode()
    {
        bonusImage.image = #imageLiteral(resourceName: "adBonusLogo")
        
        bonusImage.transform = bonusImage.transform.scaledBy(x: 0.55, y: 0.865)
        
        messageString.text = NSLocalizedString("ABVC_MESSAGE", comment: "message")
        actionButton.setTitle(NSLocalizedString("ABVC_ACTION", comment: "action"), for: .normal)
    }
    
   
    
}
