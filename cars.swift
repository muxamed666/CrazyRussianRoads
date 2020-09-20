//
//  cars.swift
//  Crazy Russian Roads
//
//  Created by Muxa Mot on 09.03.2019.
//  Copyright © 2019 Muxa Mot. All rights reserved.
//

import Foundation
import UIKit

/*

 Structure describes a car skin
 
*/

struct car
{
    var id : Int
    var carTexture : UIImage
    var carName : String
    var group : Int
    var price : Int { get { if id == 1 { return 0; } else { return (0+(group*250)); } } } //todo?
    
    init(n_id : Int, n_img : UIImage, n_name : String, n_grp : Int)
    {
        id = n_id; carTexture = n_img; carName = n_name; group = n_grp;
    }
}



/*

 Class stores cars in game
 
*/

class carsStorage
{
    
    var items : [[car]] = []
    var carNames : [String] = []
    
    
    /*
    
     Returns specified car object by its id
     
    */
    
    func getCarById(_ searchId : Int) -> car?
    {
        for item in items
        {
            for candidate in item
            {
                if candidate.id == searchId
                {
                    return candidate;
                }
            }
        }
        
        return nil;
    }
    
    
    /*
     
     Returns true if car was unlocked and saved to device.
     
    */
    
    func isAvailable(_ searchId : Int) -> Bool
    {
        for candidate in sVarsShared.availableCarsIds
        {
            if candidate == searchId
            {
                return true;
            }
        }
        
        return false;
    }
    
    
    /*
    
     Creates car list
     
    */
    
    init()
    {
        //chetvirka
        carNames.append(NSLocalizedString("CARS_CHETVIRKA", comment: "Chetvirka"))
        items.append([])
        items[0].append(car(n_id: 1, n_img: #imageLiteral(resourceName: "chetvirka_black"), n_name: NSLocalizedString("CARS_CHETVIRKA_CLASSIC", comment: "Classic"), n_grp: 1))
        items[0].append(car(n_id: 2, n_img: #imageLiteral(resourceName: "chetvirka_blue"), n_name: NSLocalizedString("CARS_CHETVIRKA_SKY", comment: "Sky"), n_grp: 1))
        items[0].append(car(n_id: 3, n_img: #imageLiteral(resourceName: "chetvirka_orange"), n_name: NSLocalizedString("CARS_CHETVIRKA_PEACH", comment: "Peach"), n_grp: 1))
        items[0].append(car(n_id: 4, n_img: #imageLiteral(resourceName: "chetvirka_yellow"), n_name: NSLocalizedString("CARS_CHETVIRKA_LEMON", comment: "Lemon"), n_grp: 1))
        items[0].append(car(n_id: 5, n_img: #imageLiteral(resourceName: "chetvirka_white"), n_name: NSLocalizedString("CARS_CHETVIRKA_SNOW", comment: "Snow"), n_grp: 1))
        
        //devyatka
        carNames.append(NSLocalizedString("CARS_DEVYATKA", comment: "Devyatka"))
        items.append([])
        items[1].append(car(n_id: 7, n_img: #imageLiteral(resourceName: "devyatka_gray"), n_name: NSLocalizedString("CARS_DEVYATKA_GRAY", comment: "Gray"), n_grp: 2))
        items[1].append(car(n_id: 8, n_img: #imageLiteral(resourceName: "devyatka_beige"), n_name: NSLocalizedString("CARS_DEVYATKA_BEIGE", comment: "Beige"), n_grp: 2))
        items[1].append(car(n_id: 9, n_img: #imageLiteral(resourceName: "devyatka_red"), n_name: NSLocalizedString("CARS_DEVYATKA_RED", comment: "Red"), n_grp: 2))
        items[1].append(car(n_id: 10, n_img: #imageLiteral(resourceName: "devyatka_lightgray"), n_name: NSLocalizedString("CARS_DEVYATKA_GRAYISH", comment: "Grayish"), n_grp: 2))
        
        //volga
        carNames.append(NSLocalizedString("CARS_VOLGA", comment: "Volga"))
        items.append([])
        items[2].append(car(n_id: 12, n_img: #imageLiteral(resourceName: "volga_white"), n_name: NSLocalizedString("CARS_VOLGA_WHITE", comment: "White"), n_grp: 3))
        items[2].append(car(n_id: 13, n_img: #imageLiteral(resourceName: "volga_green"), n_name: NSLocalizedString("CARS_VOLGA_GREEN", comment: "Green"), n_grp: 3))
        items[2].append(car(n_id: 14, n_img: #imageLiteral(resourceName: "volga_red"), n_name: NSLocalizedString("CARS_VOLGA_VINO", comment: "Vino"), n_grp: 3))
        items[2].append(car(n_id: 15, n_img: #imageLiteral(resourceName: "volga_blue"), n_name: NSLocalizedString("CARS_VOLGA_BLUISH", comment: "Bluish"), n_grp: 3))
        items[2].append(car(n_id: 16, n_img: #imageLiteral(resourceName: "volga_black"), n_name: NSLocalizedString("CARS_VOLGA_BLACKY", comment: "Blacky"), n_grp: 3))
        
        //Zapor
        carNames.append(NSLocalizedString("CARS_ZAPOR", comment: "Zapor"))
        items.append([])
        items[3].append(car(n_id: 18, n_img: #imageLiteral(resourceName: "zapor_white"), n_name: NSLocalizedString("CARS_ZAPOR_SIBERIAN", comment: "Siberian"), n_grp: 4))
        items[3].append(car(n_id: 19, n_img: #imageLiteral(resourceName: "zapor_yellow"), n_name: NSLocalizedString("CARS_ZAPOR_YELLOW", comment: "Yellow"), n_grp: 4))
        items[3].append(car(n_id: 20, n_img: #imageLiteral(resourceName: "zapor_red"), n_name: NSLocalizedString("CARS_ZAPOR_BLOODY", comment: "Bloody"), n_grp: 4))
        items[3].append(car(n_id: 21, n_img: #imageLiteral(resourceName: "zapor_gray"), n_name: NSLocalizedString("CARS_ZAPOR_DIRTY", comment: "Dirty"), n_grp: 4))
        items[3].append(car(n_id: 22, n_img: #imageLiteral(resourceName: "zapor_eggplant"), n_name: NSLocalizedString("CARS_ZAPOR_EGGPLANT", comment: "Eggplant"), n_grp: 4))
        
    }
}
