//
//  CardsCollectionViewController.swift
//  HStone
//
//  Created by xinye lei on 16/2/21.
//  Copyright © 2016年 xinye lei. All rights reserved.
//

import UIKit

class CardsCollectionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var setPickerView: UIPickerView!
    @IBOutlet weak var classFilter: UISegmentedControl!
    @IBOutlet weak var costFilter: UISegmentedControl!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!
    @IBOutlet weak var menuBar: UIView!
    
    var sets = ["All", "Classic", "GVG", "Tournament"]
    
    let classes = [ParsingCardsData.PLAYERCLASS_DRUID, ParsingCardsData.PLAYERCLASS_HUNTER, ParsingCardsData.PLAYERCLASS_MAGE, ParsingCardsData.PLAYERCLASS_PALADIN, ParsingCardsData.PLAYERCLASS_PRIEST, ParsingCardsData.PLAYERCLASS_ROGUE, ParsingCardsData.PLAYERCLASS_SHAMAN, ParsingCardsData.PLAYERCLASS_WARLOC, ParsingCardsData.PLAYERCLASS_WARRIOR, ParsingCardsData.PLAYERCLASS_NONE]
    
    var basicSet: NSArray? {
        didSet {
            
        }
    }
    
    var playerClass: String? {
        didSet {
            self.cardCollectionView.reloadData()
        }
    }
    
    @IBAction func filtByClass(sender: UISegmentedControl) {
        
    }
    @IBAction func filtByCost(sender: UISegmentedControl) {
        
    }

    
    var display: NSArray? {
        didSet {
            self.cardCollectionView.reloadData()
        }
    }
    
    func scaleImageToSize(image: UIImage, _ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setPickerView.hidden = true
        setPickerView.dataSource = self
        setPickerView.delegate = self
        cardCollectionView.dataSource = self
        cardCollectionView.delegate = self
        
        var data = ParsingCardsData.getAllCollectibleCards()
        data = ParsingCardsData.filtByClass(ParsingCardsData.PLAYERCLASS_NONE, data)
        data = ParsingCardsData.filtByCost(8, data)
        display = data

        self.classFilter.setImage(scaleImageToSize(UIImage(named: "Druid")!, CGSize(width: 10, height: 10)), forSegmentAtIndex: 0)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showMenu(sender: UIButton) {
        if (sender.titleLabel?.text == "Select Set") {
            let dis = 0.4 * self.view.bounds.size.height
            menuBarHeight.constant = dis
            self.view.bringSubviewToFront(menuBar)
            sender.setTitle("Hide", forState: .Normal)
            setPickerView.hidden = false
        }
        else {
            menuBarHeight.constant = 0
            sender.setTitle("Select Set", forState: .Normal)
            setPickerView.hidden = true
            
        }
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (complete) -> Void in
                if (complete) {

                }
        }
    }
    
    //MARK: pickerview data source method
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sets.count
    }
    
    //MARK: pickerview delegate method
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sets[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var data = ParsingCardsData.getAllCardsDic()
    }
    
    //MARK: collectionview data source method
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (display == nil) {
            return 0
        }
        return display!.count
    }

    //MARK: collectionview delegate method
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CardDisplayCell
        let dq = dispatch_queue_create("d", nil)
        dispatch_async(dq) { () -> Void in
            cell.imageView.image = nil
            let stringURL = self.display![indexPath.row][ParsingCardsData.IMAGE] as! String
            let url = NSURL(string: stringURL)
            let imageData = NSData(contentsOfURL: url!)
            let image = UIImage(data: imageData!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = image
            })
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 124, height: 177)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
