//
//  shopScreenViewController.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 02.03.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import UIKit
import Firebase

class shopScreenViewController: UIViewController, UICollectionViewDataSource
{
    //DATA
    @IBOutlet var collectionView : UICollectionView!
    @IBOutlet var carPreviewImage : UIImageView!
    @IBOutlet var carPreviewImageHeightConstraint : NSLayoutConstraint!
    @IBOutlet var listHeightConstraint : NSLayoutConstraint!
    @IBOutlet var carPriceLabel : UILabel!
    @IBOutlet var carLockedLabel : UILabel!
    @IBOutlet var carLockedImage : UIImageView!
    @IBOutlet var carLockedImageConstraint : NSLayoutConstraint!
    @IBOutlet var rubleLogoImage : UIImageView!
    @IBOutlet var scoreLabel : UILabel!
    @IBOutlet var actionButton : UIButton!
    
    override var prefersStatusBarHidden: Bool { return true; }
    let cars : carsStorage = carsStorage()
    private var currentCarOnscreenId : Int = sVarsShared.currentCarId!
    
    //METHODS
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        showDetailedCarInfo(id: sVarsShared.currentCarId!)
        //scoreLabel.text = "Points: " + String(sVarsShared.totalPointsScore);
        
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
        
        collectionView.backgroundColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.3)
        collectionView.layer.cornerRadius = 5;
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        
    }
    
    /*
     
     Get collection size
    
    */
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return cars.items[section].count;
    }
    
    
    /*
    
     Gets car cell to collectionview
     
    */
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carsCellId", for: indexPath) as! carsSelectorCell
        let car = cars.items[indexPath.section][indexPath.row]
        cell.displayContent(image: car.carTexture, title: car.carName, locked: !cars.isAvailable(car.id), price: car.price)
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCellSelected(sender:))))
        
        return cell;
    }
    
    
    /*
    
     Get car cat-e-gory spacer to collectionview
     
    */
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let spacer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "carsSpacerId", for: indexPath) as! carsSelectorSpacer
        
        spacer.spacerText.text = cars.carNames[indexPath.section]
        
        return spacer;
    }
    
    
    /*
    
     Returns number of sections in collectionview
     
    */
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return cars.items.count;
    }
    
    
    /*
    
     @objc for selector syntax
     Called when user touches one cell
     
    */
    
    @objc func handleCellSelected(sender: UITapGestureRecognizer)
    {
        let cell = sender.view as! carsSelectorCell
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        showDetailedCarInfo(id: cars.items[indexPath.section][indexPath.row].id)
        
        UIView.animate(withDuration: 0.2,
        animations: {
            cell.alpha = 0.5;
        },
        completion: { res in
            UIView.animate(withDuration: 0.2, animations: {
                cell.alpha = 1;
            })
        })
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    /*
     
     Called when user press return button
     
    */
    
    @IBAction func onReturnButtonPressed()
    {
        guard let parental = self.presentingViewController as? menuViewController
            else { return; }
        
        parental.setScreenCounters()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
    
     Shows car price and status
     
    */
    
    func showDetailedCarInfo(id : Int)
    {
        scoreLabel.text = NSLocalizedString("SHVC_POINTS", comment: "Points: ") + String(sVarsShared.totalPointsScore);
        guard let carObj = cars.getCarById(id) else { print("getCarById failed"); return; }
        currentCarOnscreenId = carObj.id
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: ["content_type" : "car", "item_id" : id])
        
        //Preview image
        carPreviewImage.image = carObj.carTexture
        carPriceLabel.text = String(carObj.price);
        
        //and its adjustments
        listHeightConstraint.constant = 26;
        self.carPreviewImageHeightConstraint.constant = 228;
        if(carObj.group == 2) {
            self.carPreviewImageHeightConstraint.constant = 216;
            self.listHeightConstraint.constant = 26 + 12;
        }
        if(carObj.group == 4) {
            self.carPreviewImageHeightConstraint.constant = 205;
            self.listHeightConstraint.constant = 26 + 23;
        }
        
        
        //check if available and buy
        if cars.isAvailable(carObj.id)
        {
            carLockedLabel.text = NSLocalizedString("SHVC_AVAILABLE", comment: "Available");
            carLockedImageConstraint.constant = 45;
            carLockedImage.image = #imageLiteral(resourceName: "menuItemUncheck")
            
            if sVarsShared.currentCarId == carObj.id
            {
                carLockedLabel.text = NSLocalizedString("SHVC_SELECTED", comment: "Selected");
                carLockedImage.image = #imageLiteral(resourceName: "menuItemCheck")
                actionButton.alpha = 0;
                //actionButton.isHidden = true;
            }
            else
            {
                if actionButton.alpha == 0 { actionButton.alpha = 1; }
                actionButton.setTitle(NSLocalizedString("SHVC_SELECT", comment: "Select!"), for: .normal)
            }
            
            rubleLogoImage.alpha = 0;
            carPriceLabel.alpha = 0;
        }
        else
        {
            if actionButton.alpha == 0 { actionButton.alpha = 1; }
            actionButton.setTitle(NSLocalizedString("SHVC_UNLOCK", comment: "Unlock!"), for: .normal)
            //actionButton.titleLabel?.text = "Unlock!"
            rubleLogoImage.alpha = 1;
            carPriceLabel.alpha = 1;
            carLockedImage.alpha = 1;
            carLockedImageConstraint.constant = 40;
            carLockedImage.image = #imageLiteral(resourceName: "menuItemLocked")
            carLockedLabel.text = NSLocalizedString("SHVC_LOCKED", comment: "Locked");
        }
        
        self.view.layoutIfNeeded()
    }
    
    
    /*
    
     Buy or select by action button
     
    */
    
    @IBAction func onActionButtonPress()
    {
        guard let carObj = cars.getCarById(currentCarOnscreenId) else { print("getCarById failed"); return; }
        
        //if car is already bought
        if cars.isAvailable(carObj.id)
        {
            //select it!
            sVarsShared.currentCarId = carObj.id
            //redraw screen
            showDetailedCarInfo(id: sVarsShared.currentCarId!)
            //go away
            return;
        }
        else
        {
            //affordable?
            if carObj.price > sVarsShared.totalPointsScore
            {
                sharedMethodsStorage.showMessageBox(title: NSLocalizedString("SHVC_CANTAFFORD", comment: "You cant afford it!"), message: NSLocalizedString("SHVC_MOREPOINTS", comment: "Earn more score points in game, to buy this car."), vc: self)
                return;
            }
            else
            {
                //yep
                sharedMethodsStorage.hurtableActionMessageBox(
                    message: NSLocalizedString("SHVC_SURE", comment: "Are you sure?"),
                    normalOption: NSLocalizedString("SHVC_UNLOCK", comment: "Unlock!"),
                    hurtableOption: NSLocalizedString("SHVC_CANCEL", comment: "Cancel"),
                    normalOptionHandler: {
                        //buy
                        Analytics.logEvent(AnalyticsEventSpendVirtualCurrency, parameters: ["item" : "car_"+String(carObj.id), "virtual_currency_name" : "points", "value" : carObj.price])
                        sVarsShared.availableCarsIds.append(carObj.id)
                        sVarsShared.rewrite()
                        sVarsShared.currentCarId = carObj.id
                        sVarsShared.totalPointsScore = sVarsShared.totalPointsScore - UInt(carObj.price)
                        self.showDetailedCarInfo(id: carObj.id) //some redraw
                        self.collectionView.reloadData()
                    },
                    hurtableOptionHandler: {
                        //do nothing!
                    },
                    vc: self)
            }
        }
    }
}



class carsSelectorCell: UICollectionViewCell
{
    @IBOutlet var carImage : UIImageView!
    @IBOutlet var carLabel : UILabel!
    @IBOutlet var carLockedIcon : UIImageView!
    @IBOutlet var rubleLogo : UIImageView!
    @IBOutlet var carPrice : UILabel!
    @IBOutlet var priceBackground : UIImageView!
    
    func displayContent(image : UIImage, title : String, locked : Bool, price : Int)
    {
        carImage.image = image;
        carLabel.text = title;
        carPrice.text = String(price)
        
        if locked
        {
            carImage.alpha = 0.6
            carLabel.alpha = 0.6
            
            priceBackground.alpha = 0.44
            carLockedIcon.alpha = 1
            rubleLogo.alpha = 1
            carPrice.alpha = 1
        }
        else
        {
            carImage.alpha = 1
            carLabel.alpha = 1
            
            priceBackground.alpha = 0
            carLockedIcon.alpha = 0
            rubleLogo.alpha = 0
            carPrice.alpha = 0
        }
    }
}


class carsSelectorSpacer : UICollectionReusableView
{
    @IBOutlet var spacerText : UILabel!
}
