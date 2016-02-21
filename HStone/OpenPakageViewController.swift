//
//  OpenPakageViewController.swift
//  HStone
//
//  Created by xinye lei on 16/2/18.
//  Copyright © 2016年 xinye lei. All rights reserved.
//

import UIKit

class OpenPakageViewController: UIViewController {
    @IBOutlet weak var packageHolder: UIView!
    @IBOutlet weak var dragDestination: UIView!
    @IBOutlet var card: [UIView]!

    var cardsGot: [(NSDictionary, Bool)] = []
    var imageCache: [UIImage] = []
    var imageDisplayViews: [UIImageView] = []
    //collectible
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UIPanGestureRecognizer(target: self, action: Selector("drag:"))
        self.view.addGestureRecognizer(gesture)
        let frame = self.packageHolder.frame
        let imageView = UIImageView(frame: frame)
        imageView.image = UIImage(named: "classicPack")
        self.view.addSubview(imageView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var dragingImageView: UIImageView?
    
    func drag(recongnizer:UIPanGestureRecognizer) {
        let location = recongnizer.locationInView(self.view)
        if (recongnizer.state == UIGestureRecognizerState.Began) {
            if (isLocationInView(location, self.packageHolder)) {
                var frame = self.packageHolder.frame
                frame.origin = location
                let imageView = UIImageView(frame: frame)
                imageView.image = UIImage(named: "classicPack")
                self.view.addSubview(imageView)
                dragingImageView = imageView
            }
        }
        if (dragingImageView != nil) {
            dragingImageView!.center = location
        }
        if (recongnizer.state == UIGestureRecognizerState.Ended) {
            if (!isLocationInView(location, self.dragDestination)) {
                dragingImageView!.removeFromSuperview()
                dragingImageView = nil
            }
            else {
                self.prepareOpenPack()
                dragingImageView!.frame = self.dragDestination.frame
                UIView.animateWithDuration(3, animations: { () -> Void in
                    self.dragingImageView!.hidden = true
                    }, completion: { (complete) -> Void in
                        if (complete) {
                            self.dragingImageView!.removeFromSuperview()
                            self.dragingImageView = nil
                        }
                })
            }
        }
    }
    
    func prepareOpenPack() {
        self.view.gestureRecognizers![0].enabled = false
        var set = ParsingCardsData.getCardsForCardSet(ParsingCardsData.TOURNAMENT)!
        set = ParsingCardsData.getCollectibleCards(set)
        let common = ParsingCardsData.getCardsWithRarity(ParsingCardsData.RARITY_COMMON, set)
        let rare = ParsingCardsData.getCardsWithRarity(ParsingCardsData.RARITY_RARE, set)
        let epic = ParsingCardsData.getCardsWithRarity(ParsingCardsData.RARITY_EPIC, set)
        let leg = ParsingCardsData.getCardsWithRarity(ParsingCardsData.RARITY_LEGENDARY, set)
        var gotRareCard = false
        for cardView in self.card {
            let imageView = UIImageView(frame: self.dragDestination.frame)
            imageView.image = UIImage(named: "cardBack")
            self.view.addSubview(imageView)
            let index = self.card.indexOf(cardView)!
            let delay = Double(index) * 0.1
            UIView.animateWithDuration(0.1, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                imageView.center = cardView.center
                }, completion: nil)
            imageDisplayViews.append(imageView)
            let rarityProb = Int(arc4random() % 100)
            let goldProb = Int(arc4random() % 100)
            var selectionSet: NSArray
            switch (rarityProb) {
            case(95..<100): selectionSet = leg; gotRareCard = true
            case(85..<95): selectionSet = epic; gotRareCard = true
            case(75..<85): selectionSet = rare; gotRareCard = true
            default: selectionSet = common
            }
            let cardIndex = Int(arc4random()) % selectionSet.count
            let gold = goldProb > 90 ? true : false
            let cardInfo = selectionSet[cardIndex] as! NSDictionary
            self.cardsGot.append((cardInfo, gold))
        }
        if (!gotRareCard) {
            let cardIndex = Int(arc4random()) % rare.count
            let cardInfo = rare[cardIndex] as! NSDictionary
            self.cardsGot.removeLast()
            self.cardsGot.append((cardInfo, false))
        }
        downloadImages()
    }
    
    func downloadImages() {
        let downloadQ = dispatch_queue_create("download", nil)
        self.dragDestination.hidden = true
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.center = self.dragDestination.center
        self.view.addSubview(spinner)
        spinner.startAnimating()
        dispatch_async(downloadQ) { () -> Void in
            var local:[UIImage] = []
            for card in self.cardsGot {
                let info = card.0
                let imageUrlString = card.1 ? info[ParsingCardsData.IMAGE_GOLD] : info[ParsingCardsData.IMAGE]
                let url = NSURL(string: imageUrlString as! String)
                let imageData = NSData(contentsOfURL: url!)
                let image = UIImage(data: imageData!)
                local.append(image!)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.imageCache.appendContentsOf(local)
                spinner.stopAnimating()
                let tapGesture = UILongPressGestureRecognizer(target: self, action: Selector("press:"))
                tapGesture.minimumPressDuration = 0.1
                self.view.addGestureRecognizer(tapGesture)
            })
        }
    }
    
    var num = 0
    func press(recongizer:UILongPressGestureRecognizer) {
        let location = recongizer.locationInView(self.view)
        for displayView in imageDisplayViews {
            if (isLocationInView(location, displayView)) {
                if (recongizer.state == .Ended) {
                    if (displayView.image == UIImage(named: "cardBack")) {
                        num++
                        let index = imageDisplayViews.indexOf(displayView)
                        UIView.transitionWithView(displayView, duration: 1, options: [.CurveEaseInOut, .TransitionFlipFromRight], animations: { () -> Void in
                            displayView.image = self.imageCache[index!]
                            }, completion: { (complete) -> Void in
                                if (self.num == 5) {
                                    self.view.gestureRecognizers![1].enabled = false
                                    self.num = 0
                                    let button = UIButton(frame: self.dragDestination!.frame)
                                    button.frame.size.height /= 10
                                    button.center = self.dragDestination.center
                                    button.setTitle("OK", forState: .Normal)
                                    button.backgroundColor = UIColor.blueColor()
                                    button.addTarget(self, action: Selector("dismiss:"), forControlEvents: .TouchUpInside)
                                    self.view.addSubview(button)
                                }
                        })
                    }
                }
                else {
                    
                }
            }
        }
    }
    
    func dismiss(sender: UIButton) {
        sender.removeFromSuperview()
        for view in imageDisplayViews {
            view.removeFromSuperview()
        }
        imageDisplayViews.removeAll()
        imageCache.removeAll()
        cardsGot.removeAll()
        self.view.gestureRecognizers!.removeLast()
        self.view.gestureRecognizers![0].enabled = true
    }
    
    func isLocationInView(location: CGPoint, _ view: UIView) -> Bool {
        let origin = view.frame.origin
        let width = view.frame.size.width
        let height = view.frame.size.height
        if (location.x > origin.x && location.x < origin.x + width) {
            if (location.y > origin.y && location.y < origin.y + height) {
                return true
            }
        }
        return false
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
