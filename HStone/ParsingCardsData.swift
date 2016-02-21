//
//  ParsingCardsData.swift
//  HStone
//
//  Created by xinye lei on 16/2/20.
//  Copyright © 2016年 xinye lei. All rights reserved.
//

import Foundation


class ParsingCardsData {
    
    static let BLACKROCK_MOUNTAIN = "Blackrock Mountain"
    static let PROMOTION = "Promotion"
    static let CREDITS = "Credits"
    static let HERO_SKINS = "Hero Skins"
    static let CLASSIC = "Classic"
    static let TAVERN_BRAWL = "Tavern Brawl"
    static let REWARD = "Reward"
    static let EXPLORERS = "The League of Explorers"
    static let GVG = "Goblins vs Gnomes"
    static let MISSIONS = "Missions"
    static let BASIC = "Basic"
    static let TOURNAMENT = "The Grand Tournament"
    static let NAXX = "Naxxramas"
    static let DEBUG = "Debug"
    static let SYSTEM = "System"
    static let ALL = "All"
    
    static let COLLECTIBLE = "collectible"
    static let COST = "cost"
    static let NAME = "name"
    
    static let RARITY = "rarity"
    static let RARITY_COMMON = "Common"
    static let RARITY_RARE = "Rare"
    static let RARITY_EPIC = "Epic"
    static let RARITY_LEGENDARY = "Legendary"
    
    static let PLAYERCLASS = "playerClass"
    static let PLAYERCLASS_SHAMAN = "Shaman"
    static let PLAYERCLASS_MAGE = "Mage"
    static let PLAYERCLASS_WARLOC = "Warlock"
    static let PLAYERCLASS_PALADIN = "Paladin"
    static let PLAYERCLASS_HUNTER = "Hunter"
    static let PLAYERCLASS_PRIEST = "Priest"
    static let PLAYERCLASS_WARRIOR = "Warrior"
    static let PLAYERCLASS_DRUID = "Druid"
    static let PLAYERCLASS_ROGUE = "Rogue"
    
    static let IMAGE = "img"
    static let IMAGE_GOLD = "imgGold"
    
    
    static func getAllCardsDic() -> NSDictionary {
        let asset = NSDataAsset(name: "cards")
        let json = try?NSJSONSerialization.JSONObjectWithData(asset!.data, options: NSJSONReadingOptions.AllowFragments)
        return json as! NSDictionary
    }
    
    static func getCardsForCardSet(cardSetName: String) -> NSArray? {
        let dic = ParsingCardsData.getAllCardsDic()
        return dic[cardSetName] as? NSArray
    }
    
    static func getCollectibleCards(cardSet: NSArray) -> NSArray {
        let res = NSMutableArray()
        for card in cardSet {
            let cardDic = card as! NSDictionary
            if (cardDic[COLLECTIBLE] != nil && cardDic[COLLECTIBLE] as! Int  == 1) {
                res.addObject(cardDic)
            }
        }
        res.sortUsingComparator { (obj1, obj2) -> NSComparisonResult in
            let card1 = obj1 as! NSDictionary
            let card2 = obj2 as! NSDictionary
            let cost1 = card1[COST] as! Int
            let cost2 = card2[COST] as! Int
            if (cost1 < cost2) {
                return NSComparisonResult.OrderedAscending
            }
            else if (cost1 > cost2) {
                return NSComparisonResult.OrderedDescending
            }
            else {
                let name1 = card1[NAME] as! String
                let name2 = card2[NAME] as! String
                return name1.compare(name2)
            }
        }
        return res
    }
    
    static func getCardsWithRarity(rarity: String, _ cardSet: NSArray) -> NSArray {
        let res = NSMutableArray()
        for card in cardSet {
            let cardDic = card as! NSDictionary
            if (cardDic[RARITY] != nil && cardDic[RARITY] as! String == rarity) {
                res.addObject(card)
            }
        }
        return res
    }
    
    static func getCardsWithPlayerClass(playerClass: String, _ cardSet: NSArray) -> NSArray {
        let res = NSMutableArray();
        for card in cardSet {
            let cardDic = card as! NSDictionary
            if (cardDic[PLAYERCLASS] != nil && cardDic[PLAYERCLASS] as! String == playerClass) {
                res.addObject(card)
            }
        }
        return res
    }
    
}