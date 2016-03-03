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
    @IBOutlet var card: NSArray!
    @IBOutlet weak var menuBar: UIView!
    @IBOutlet weak var menuBarHeight: NSLayoutConstraint!

    @IBOutlet weak var cardStatsLabel: UILabel!
    let COMMON = 0
    let RARE = 2
    let EPIC = 4
    let LEGENDARY = 6
    var cardStats = [Int](count: 8, repeatedValue: 0)
    
    @IBOutlet weak var packLabel: UILabel!
    var packStats: [Int] = [0, 0, 0] {
        didSet {
            packLabel.text = String(format: "Classic: %d\n\nGVG: %d\n\nTournament: %d", packStats[0], packStats[1], packStats[2])
        }
    }
    
    
    
    var cardsGot: [(NSDictionary, Bool)] = []
    var imageCache: [UIImage] = []
    var imageDisplayViews: [UIImageView] = []
    
    
    var cardSet: String? {
        didSet {
            for view in imageDisplayViews {
                view.removeFromSuperview()
            }
            imageDisplayViews.removeAll()
            imageCache.removeAll()
            cardsGot.removeAll()
            if (self.view.gestureRecognizers?.count == 2) {
                self.view.gestureRecognizers!.removeLast()
            }
            self.view.gestureRecognizers![0].enabled = true
            switch (cardSet!) {
            case(ParsingCardsData.GVG): packageHolderImageView?.image = UIImage(named: "gvgPack")
            case(ParsingCardsData.TOURNAMENT): packageHolderImageView?.image = UIImage(named: "touPack")
            default: packageHolderImageView?.image = UIImage(named: "classicPack")
            }
        }
    }
    var packageHolderImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UIPanGestureRecognizer(target: self, action: Selector("drag:"))
        self.view.addGestureRecognizer(gesture)
        let frame = self.packageHolder.frame
        let imageView = UIImageView(frame: frame)
        imageView.image = UIImage(named: "classicPack")
        imageView.contentMode = .ScaleAspectFit
        self.view.addSubview(imageView)
        packageHolderImageView = imageView
        cardSet = ParsingCardsData.CLASSIC

        var bgframe = self.view.frame
        bgframe.origin.y = card[0].frame.origin.y * 1.1
        bgframe.size.height -= menuBar.frame.size.height  + packageHolder.frame.size.height
        let bgview = UIImageView(frame: bgframe)
        bgview.image = UIImage(named: "PackOpeningTray")
        self.view.addSubview(bgview)
        self.view.sendSubviewToBack(bgview)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let holderbgframe = CGRect(x: self.view.bounds.origin.x, y: self.packageHolder.frame.origin.y, width: self.view.frame.size.width, height: 1.1 * (self.card[0].frame.origin.y - self.menuBar.frame.size.height))
        let holderbgView = UIImageView(frame: holderbgframe)
        holderbgView.image = UIImage(named: "holder")
        self.view.addSubview(holderbgView)
        self.view.bringSubviewToFront(packageHolderImageView!)
        self.view.bringSubviewToFront(packLabel)
        self.view.bringSubviewToFront(cardStatsLabel)
        packageHolderImageView?.frame = packageHolder.frame
        packageHolderImageView?.layer.cornerRadius = 0.1 * packageHolder.frame.size.width
        packageHolderImageView?.layer.masksToBounds = true
    }
    var dragingImageView: UIImageView?
    
    func drag(recongnizer:UIPanGestureRecognizer) {
        let location = recongnizer.locationInView(self.view)
        if (recongnizer.state == UIGestureRecognizerState.Began) {
            if (isLocationInView(location, self.packageHolder)) {
                var frame = self.packageHolder.frame
                frame.origin = location
                let imageView = UIImageView(frame: frame)
                imageView.image = packageHolderImageView?.image
                self.view.addSubview(imageView)
                imageView.layer.cornerRadius = imageView.frame.size.width * 0.1
                imageView.layer.masksToBounds = true
                dragingImageView = imageView
            }
        }
        if (dragingImageView != nil) {
            dragingImageView!.center = location
        }
        if (recongnizer.state == UIGestureRecognizerState.Ended && dragingImageView != nil) {
            if (!isLocationInView(location, self.dragDestination)) {
                if (dragingImageView != nil) {
                    dragingImageView!.removeFromSuperview()
                    dragingImageView = nil
                }
            }
            else {
                self.prepareOpenPack()
                self.menuBar.subviews[0].userInteractionEnabled = false
                dragingImageView!.frame = self.dragDestination.frame
                self.dragingImageView!.hidden = true
                self.dragingImageView!.removeFromSuperview()
                self.dragingImageView = nil
            }
        }
    }
    
    func prepareOpenPack() {
        switch(cardSet!) {
        case(ParsingCardsData.CLASSIC): packStats[0]++
        case(ParsingCardsData.GVG): packStats[1]++
        default: packStats[2]++
        }
        self.view.gestureRecognizers![0].enabled = false
        var set = ParsingCardsData.getCardsForCardSet(cardSet!)!
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
            let index = self.card.indexOfObject(cardView)
            let delay = Double(index) * 0.1
            UIView.animateWithDuration(0.1, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                imageView.center = cardView.center
                }, completion: nil)
            imageDisplayViews.append(imageView)
            let rarityProb = Int(arc4random() % 100)
            let goldProb = Int(arc4random() % 100)
            var selectionSet: NSArray
            var statsIndex = 0
            switch (rarityProb) {
            case(95..<100): selectionSet = leg; gotRareCard = true; statsIndex = LEGENDARY
            case(85..<95): selectionSet = epic; gotRareCard = true; statsIndex = EPIC
            case(75..<85): selectionSet = rare; gotRareCard = true; statsIndex = RARE
            default: selectionSet = common; statsIndex = COMMON
            }
            let cardIndex = Int(arc4random()) % selectionSet.count
            let gold = goldProb > 90 ? true : false
            if (gold) {
                cardStats[statsIndex + 1]++
            }
            else {
                cardStats[statsIndex]++
            }
            let cardInfo = selectionSet[cardIndex] as! NSDictionary
            self.cardsGot.append((cardInfo, gold))
        }
        if (!gotRareCard) {
            let cardIndex = Int(arc4random()) % rare.count
            let cardInfo = rare[cardIndex] as! NSDictionary
            self.cardsGot.removeLast()
            self.cardsGot.append((cardInfo, false))
            cardStats[COMMON]--
            cardStats[RARE]++
        }
        downloadImages()
    }
    
    func downloadImages() {
        let downloadQ = dispatch_queue_create("download", nil)
        self.dragDestination.hidden = true
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
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
                let image = UIImage.animatedImageWithAnimatedGIFData(imageData!)
                local.append(image!)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.imageCache.appendContentsOf(local)
                spinner.stopAnimating()
                let tapGesture = UILongPressGestureRecognizer(target: self, action: Selector("press:"))
                tapGesture.minimumPressDuration = 0.05
                self.view.addGestureRecognizer(tapGesture)
            })
        }
    }
    
    var num = 0
    func press(recongizer:UILongPressGestureRecognizer) {
        let location = recongizer.locationInView(self.view)
        for displayView in imageDisplayViews {
            if (isLocationInView(location, displayView)) {
                let index = imageDisplayViews.indexOf(displayView)!
                if (recongizer.state == .Began && displayView.image == UIImage(named: "cardBack")) {
                    let cardInfo = cardsGot[index].0
                    if (cardInfo[ParsingCardsData.RARITY] as! String == ParsingCardsData.RARITY_RARE) {
                        addEmissionToViewWithColor(card[index] as! UIView, color: UIColor.blueColor())
                    }
                    if (cardInfo[ParsingCardsData.RARITY] as! String == ParsingCardsData.RARITY_EPIC) {
                        addEmissionToViewWithColor(card[index] as! UIView, color: UIColor.purpleColor())
                    }
                    if (cardInfo[ParsingCardsData.RARITY] as! String == ParsingCardsData.RARITY_LEGENDARY) {
                        addEmissionToViewWithColor(card[index] as! UIView, color: UIColor.orangeColor())
                    }
                }
                else {
                    let view = card[index] as! UIView
                    view.layer.sublayers?.removeAll()
                }
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
                                    button.frame.size.height /= 2
                                    button.center = self.dragDestination.center
                                    button.setTitle("OK", forState: .Normal)
                                    button.setBackgroundImage(UIImage(named: "button"), forState: .Normal)
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
        cardStatsLabel.text = String(format: "Common: %d / %d\n\nRare: %d / %d\n\nEpic: %d / %d\n\nLegendary: %d / %d", cardStats[0], cardStats[1], cardStats[2], cardStats[3], cardStats[4], cardStats[5], cardStats[6], cardStats[7])
        UIView.animateWithDuration(1, delay: 0, options: [], animations: { () -> Void in
            sender.alpha = 0
            for view in self.imageDisplayViews {
                view.alpha = 0
            }
            }) { (complete) -> Void in
                if (complete) {
                    sender.removeFromSuperview()
                    self.menuBar.subviews[0].userInteractionEnabled = true
                    for view in self.imageDisplayViews {
                        view.removeFromSuperview()
                    }
                    self.imageDisplayViews.removeAll()
                    self.imageCache.removeAll()
                    self.cardsGot.removeAll()
                    self.view.gestureRecognizers!.removeLast()
                    self.view.gestureRecognizers![0].enabled = true
                }
        }
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
    
    @IBAction func selectCardSet(sender: UIButton) {
        if (sender.titleLabel?.text == "Card Set") {
            self.view.bringSubviewToFront(self.menuBar)
            self.menuBarHeight.constant -= self.packageHolder.frame.size.height
            self.view.gestureRecognizers![0].enabled = false
            sender.setTitle("Hide", forState: .Normal)
            self.view.layoutIfNeeded()
            self.addPackViews()
        }
        else {
            self.removePackViews()
            self.menuBarHeight.constant = 0
            sender.setTitle("Card Set", forState: .Normal)
            self.view.gestureRecognizers![0].enabled = true
        }
    }
    
    var packViewsInMenuBar: [UIImageView]? = []
    func addPackViews() {
        var origin = self.menuBar.bounds.origin
        let width = self.packageHolder.frame.size.width
        let height = self.packageHolder.frame.size.height
        origin.y = origin.y + self.menuBar.bounds.size.height - height
        let frame1 = CGRect(x: origin.x, y: origin.y, width: width, height: height)
        var frame2 = frame1, frame3 = frame1
        frame2.origin.x += width * 1.1
        frame3.origin.x += width * 1.1 + width * 1.1
        let view1 = UIImageView(frame: frame1)
        let view2 = UIImageView(frame: frame2)
        let view3 = UIImageView(frame: frame3)
        view1.image = UIImage(named: "classicPack")
        view2.image = UIImage(named: "gvgPack")
        view3.image = UIImage(named: "touPack")
        packViewsInMenuBar?.appendContentsOf([view1, view2, view3])
        for view in self.packViewsInMenuBar! {
            view.layer.cornerRadius = width * 0.1
            view.layer.masksToBounds = true
            view.frame.origin.y = -view.frame.origin.y
            self.menuBar.addSubview(view)
        }
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            view1.frame = frame1
            view2.frame = frame2
            view3.frame = frame3
            }, completion: nil)
 
        let tapGes = UITapGestureRecognizer(target: self, action: Selector("tapInMenuBar:"))
        self.menuBar.addGestureRecognizer(tapGes)
    }
    func removePackViews() {
        UIView.transitionWithView(view, duration: 0.5, options: [.TransitionCrossDissolve], animations: { () -> Void in
            for view in self.packViewsInMenuBar! {
                view.hidden = true
            }
            }, completion: { (complete) -> Void in
                if (complete) {
                    for view in self.packViewsInMenuBar! {
                        view.removeFromSuperview()
                    }
                    self.view.sendSubviewToBack(self.menuBar)
                }
        })
        packViewsInMenuBar?.removeAll()
    }
    func tapInMenuBar(sender: UITapGestureRecognizer) {
        let location = sender.locationInView(self.menuBar)
        for setView in packViewsInMenuBar! {
            if (isLocationInView(location, setView)) {
                let index = packViewsInMenuBar?.indexOf(setView)
                switch (index!) {
                case(1): cardSet = ParsingCardsData.GVG
                case(2): cardSet = ParsingCardsData.TOURNAMENT
                default: cardSet = ParsingCardsData.CLASSIC
                }
            }
        }
        removePackViews()
        for view in self.menuBar.subviews {
            if (view.isKindOfClass(UIButton.self)) {
                let button = view as! UIButton
                selectCardSet(button)
            }
        }
    }
    
    func addEmissionToViewWithColor(view: UIView, color: UIColor) {
        if (view.layer.sublayers?.count > 0) {
            return
        }
        let rect = CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y, width: view.bounds.size.width, height: view.bounds.size.height)
        let emitter = CAEmitterLayer()
        emitter.frame = rect
        view.layer.addSublayer(emitter)
        emitter.emitterShape = kCAEmitterLayerPoint
        emitter.emitterPosition = CGPoint(x: rect.size.width / 2, y: rect.height / 2)
        emitter.emitterSize = rect.size
        let cell = CAEmitterCell()
        let image = scaleImageToSize(UIImage(named: "DustGray")!, CGSize(width: 16, height: 16))
        cell.contents = image.CGImage
        cell.birthRate = 200
        cell.lifetime = 3.5
        cell.color = color.CGColor
        cell.emissionLongitude = CGFloat(-M_PI_2)
        cell.velocityRange = 200
        cell.emissionRange = CGFloat(M_PI * 2)
        cell.scaleRange = 0.8
        emitter.emitterCells = [cell]
    }
    
    func scaleImageToSize(image: UIImage, _ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg
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
