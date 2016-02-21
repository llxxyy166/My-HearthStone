//
//  HearthStoneAPI.swift
//  HStone
//
//  Created by xinye lei on 16/2/14.
//  Copyright © 2016年 xinye lei. All rights reserved.
//

import Foundation

let KEY = "bbLmx472W8mshaJG4jQJI4lIE04Yp1pfIRIjsna37fCiC4EtZL"

func urlForSingleCardByUniqueID(uniqueId: String) -> NSURL? {
    let stringURL = "https://omgvamp-hearthstone-v1.p.mashape.com/cards/\(uniqueId)?mashape-key=\(KEY)"
    return NSURL(string: stringURL)
}

func downloadContentsWithURL(URL: NSURL) -> AnyObject? {
    let data = NSData(contentsOfURL: URL)
    if (data == nil) {
        print("not found")
        return nil
    }
    do {
        let res = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
        return res
    } catch {
        print("error")
        return nil
    }
}