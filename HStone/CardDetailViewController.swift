//
//  CardDetailViewController.swift
//  HStone
//
//  Created by xinye lei on 16/2/14.
//  Copyright © 2016年 xinye lei. All rights reserved.
//

import UIKit

class CardDetailViewController: UIViewController {
    
    @IBOutlet weak var normalCardImageView: UIImageView!
    
    @IBOutlet weak var goldCardImageView: UIWebView!

    
    @IBOutlet weak var cardFlavor: UITextView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var cardDetail: NSDictionary? {
        didSet {
            let downloadQueue = dispatch_queue_create("download", nil)
            dispatch_async(downloadQueue) { () -> Void in
                let image = self.cardDetail!["img"] as! String
                let imageGold = self.cardDetail!["imgGold"] as! String
                let imageURL = NSURL(string: image)
                let imageGoldURL = NSURL(string: imageGold)
                let imageData = NSData(contentsOfURL: imageURL!)
                let imageGoldData = NSData(contentsOfURL: imageGoldURL!)
                let imageA = UIImage(data: imageData!)
                let imageB = UIImage.animatedImageWithAnimatedGIFData(imageGoldData!)
                let flavor = self.cardDetail!["flavor"] as! String
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.normalCardImageView.image = imageB
                    self.goldCardImageView.loadData(imageGoldData!, MIMEType: "image/gif", textEncodingName: String(), baseURL: NSURL())
                    self.cardFlavor.text = flavor
                    self.spinner.stopAnimating()
                })
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner.startAnimating()
        let url = urlForSingleCardByUniqueID("EX1_572")
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let array = downloadContentsWithURL(url!) as? NSArray
            self.cardDetail = array![0] as? NSDictionary
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
