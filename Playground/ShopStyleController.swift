//
//  ShopStyleController.swift
//  Playground
//
//  Created by Blaine on 6/27/17.
//  Copyright © 2017 Blaine. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

class ShopStyleController {

    func requestClothing(withColor: UIColor, category: ClothingCategory, completionHandler: @escaping ([ClothingItem]) -> Swift.Void) {
        
        print("RequestClothing")
        var baseURL = "https://api.shopstyle.com/api/v2/products?pid=uid8609-39165647-91&limit=50&sort=Popular"
        let colorText: String!
        
        switch withColor {
        case UIColor.brown:
            colorText = "&fl=c1"
        case UIColor.orange:
            colorText = "&fl=c3"
        case UIColor.yellow:
            colorText = "&fl=c4"
        case UIColor.red:
            colorText = "&fl=c7"
        case UIColor.purple:
            colorText = "&fl=c8"
        case UIColor.blue:
            colorText = "&fl=c10"
        case UIColor.green:
            colorText = "&fl=c13"
        case UIColor.gray:
            colorText = "&fl=c14"
        case UIColor.white:
            colorText = "&fl=c15"
        case UIColor.black:
            colorText = "&fl=c16"
        case UIColor.pink:
            colorText = "&fl=c17"
        case UIColor.gold:
            colorText = "&fl=c18"
        case UIColor.silver:
            colorText = "&fl=c19"
        case UIColor.beige:
            colorText = "&fl=c20"
        default:
            colorText = "&fl=c7"
        }

        baseURL.append("&cat=")
        baseURL.append(category.rawValue)
        baseURL.append(colorText)
        
        let fileURL = URL(string: baseURL)
        requestFileURL(fileURL: fileURL!, itemsCompletionHandler: completionHandler)
    }
    
   private func requestFileURL(fileURL: URL, itemsCompletionHandler: @escaping ([ClothingItem]) -> Swift.Void) {
        let dataTask = URLSession.shared.dataTask(with: fileURL, completionHandler: {
            data, response, error in

            if error != nil {
                print("RequestFileURLError:\(error!)")
            }
            
            do {
                if let d = data, let dictionary = try JSONSerialization.jsonObject(with: d, options: []) as? [String: AnyObject] {

                    let products = dictionary["products"] as! [NSDictionary]
                    
                    var imageURLs = [ClothingItem]()
                    
                    for itemDict in products {
                        let clickUrl = itemDict["clickUrl"] as! String
                        let price = itemDict["priceLabel"] as! String
                        let name = itemDict["name"] as! String
                        let text = itemDict["description"] as! String
                        let image = itemDict["image"] as! NSDictionary
                        let sizes = image["sizes"] as! NSDictionary
                        let bestImageDict = sizes["Best"] as! NSDictionary
                        let phoneImageDict = sizes["IPhone"] as! NSDictionary

                        let thumbnailImageURL = phoneImageDict["url"] as! String
                        let imageURL = bestImageDict["url"] as! String

                        let item = ClothingItem()
                        item.thumbnailURL = URL(string: thumbnailImageURL)!
                        item.imageURL = URL(string: imageURL)!
                        item.webURL = URL(string: clickUrl)!
                        item.text = text
                        item.price = price
                        item.name = name
                        imageURLs.append(item)
                    }
                    
                    DispatchQueue.main.async {
                        itemsCompletionHandler(imageURLs)
                    }
                    
                }
            } catch {
                print("Error \(error)")
            }
        })
        
        dataTask.resume()
    }
}

class ClothingItem {
    var thumbnailURL: URL!
    var imageURL: URL!
    var text: String!
    var price: String!
    var name: String!
    var webURL: URL!
}

let ClothingCategoryKey = "ClothingCategory"
let ClothingColorKey = "ClothingColor"

enum ClothingCategory: String {
    case mensTees = "mens-tees-and-tshirts"
    case mensFormal = "mens-dress-shirts"
    case mensCasual = "mens-longsleeve-shirts"
    case mensSocks = "mens-socks"
    case mensBelts = "mens-belts"
    case mensPants = "mens-pants"
    case mensShorts = "mens-shorts"
    case mensSweaters = "mens-sweaters"
    case mensAthleticShirts = "mens-athletic-shirts"
    case mensTies = "mens-ties"
    case mensUnderwear = "mens-briefs"
    case mensHats = "mens-hats"
    case mensSuits = "mens-suits"
    case mensVests = "mens-vests"
    case mensJackets = "mens-jackets"
    case mensShoes = "mens-shoes"
}

extension ClothingCategory {
    func displayName() -> String {

        let displayName: String!

        switch self {
        case .mensTees:
           displayName = "Tees"
        case .mensFormal:
            displayName = "Formal"
        case .mensCasual:
            displayName = "Casual"
        case .mensSocks:
            displayName = "Socks"
        case .mensBelts:
            displayName = "Belts"
        case .mensPants:
            displayName = "Pants"
        case .mensShorts:
            displayName = "Shorts"
        case .mensSweaters:
            displayName = "Sweaters"
        case .mensAthleticShirts:
            displayName = "Athletic"
        case .mensTies:
            displayName = "Ties"
        case .mensUnderwear:
            displayName = "Underwear"
        case .mensHats:
            displayName = "Hats"
        case .mensSuits:
            displayName = "Suits"
        case .mensVests:
            displayName = "Vests"
        case .mensJackets:
            displayName = "Jackets"
        case .mensShoes:
            displayName = "Shoes"
        }

        return displayName
    }
}

extension UIColor {
    func displayName() -> String {

        let displayName: String!

        switch self {
        case UIColor.brown:
            displayName = "Brown"
        case UIColor.orange:
            displayName = "Orange"
        case UIColor.yellow:
            displayName = "Yellow"
        case UIColor.red:
            displayName = "Red"
        case UIColor.purple:
            displayName = "Purple"
        case UIColor.blue:
            displayName = "Blue"
        case UIColor.green:
            displayName = "Green"
        case UIColor.gray:
            displayName = "Gray"
        case UIColor.white:
            displayName = "White"
        case UIColor.black:
            displayName = "Black"
        case UIColor.pink:
            displayName = "Pink"
        case UIColor.gold:
            displayName = "Gold"
        case UIColor.silver:
            displayName = "Silver"
        case UIColor.beige:
            displayName = "Beige"
        default:
            displayName = "Color"
        }

        return displayName
    }
}

extension Array where Element: Hashable {
    func after(item: Element?) -> Element {
        if item == nil {
            return first!
        }
        
        if let index = index(of: item!), index + 1 < count {
            return self[index + 1]
        }
        
        return first!
    }
}

class SMCell: UICollectionViewCell {
    @IBOutlet weak var imageViewBackgroundView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
}
