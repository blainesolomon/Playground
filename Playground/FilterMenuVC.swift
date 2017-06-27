//
//  FilterMenuVC.swift
//  Playground
//
//  Created by Blaine on 6/27/17.
//  Copyright © 2017 Blaine. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class FilterMenuVC: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: 98, height: 98)

        if filterModeIsCategory == true {
            let selectedCategory = ClothingCategory.mensShorts
            let indexOfSelectedCategory = categoryCollection.index(of: selectedCategory)
             lastSelectedIndexPath = IndexPath(item: indexOfSelectedCategory!, section: 0)
        } else {
            let selectedColor = UIColor.red
            let indexOfSelectedColor = colorCollection.index(of: selectedColor)
            lastSelectedIndexPath = IndexPath(item: indexOfSelectedColor!, section: 0)
        }
    }

    // MARK: - Collection

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SMCell

        if filterModeIsCategory == true {
            let catAtIndex = categoryCollection[indexPath.item]
            cell.imageView.image = categoryIcons[indexPath.item]
            cell.imageView.tintColor = .black
            cell.label.text = catAtIndex.displayName().uppercased()

            if indexPath == lastSelectedIndexPath {
                cell.imageView.tintColor = navigationController?.navigationBar.barTintColor
            }

        } else {
            let colorAtIndex = colorCollection[indexPath.item]
            cell.imageView.image = #imageLiteral(resourceName: "ColorCheck")
            cell.imageView.tintColor = colorAtIndex
            cell.label.text = colorAtIndex.displayName().uppercased().uppercased()
            cell.imageViewBackgroundView.backgroundColor = .clear

            if indexPath == lastSelectedIndexPath {
                cell.imageViewBackgroundView.backgroundColor = .black
            }
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SMCell
        var lastCell: SMCell?

        if let lastIndexPath = lastSelectedIndexPath {
            lastCell = collectionView.cellForItem(at: lastIndexPath) as? SMCell
        }

        if indexPath == lastSelectedIndexPath {
            return
        }

        lastSelectedIndexPath = indexPath

        if filterModeIsCategory == true {
            let catAtIndex = categoryCollection[indexPath.item]
            delegate?.selectedCategory = catAtIndex
            cell.imageView.tintColor = navigationController?.navigationBar.barTintColor
            lastCell?.imageView.tintColor = .black
        } else {
            let colorAtIndex = colorCollection[indexPath.item]
            delegate?.selectedColor = colorAtIndex
            cell.imageViewBackgroundView.backgroundColor = .black
            lastCell?.imageViewBackgroundView.backgroundColor = .clear

            if colorAtIndex == .black {
                cell.imageViewBackgroundView.backgroundColor = view.tintColor
            }
        }

        delegate?.loadSelectedItems()
    }

    // MARK: - BTS

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if filterModeIsCategory == true {
            return categoryCollection.count
        }

        return colorCollection.count
    }

    func reloadData() {
        collectionView?.reloadData()

        var offset = collectionView!.contentOffset
        offset.y = collectionView!.contentSize.height + collectionView!.contentInset.bottom - collectionView!.bounds.size.height
        collectionView!.contentOffset = offset
    }

    func itemSize() -> CGSize {
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let spaceBetweenItems = layout.minimumInteritemSpacing
        let leftMargin = layout.sectionInset.left
        let widthOfCanvas = view.frame.size.width

        let itemSizeSum = widthOfCanvas - leftMargin - (spaceBetweenItems * 4) - leftMargin
        let itemSize = itemSizeSum/5
        return CGSize(width: itemSize, height: itemSize)
    }

    // MARK: - Properties

    weak var delegate: ExploreVC?
    var lastSelectedIndexPath: IndexPath?
    @IBInspectable var filterModeIsCategory = true

    let allIcons = [#imageLiteral(resourceName: "Shirts"), #imageLiteral(resourceName: "ColorCheck")]
    let allNames = ["Focus", "Color"]

    let categoryIcons = [#imageLiteral(resourceName: "Shirts"), #imageLiteral(resourceName: "DressShirt"), #imageLiteral(resourceName: "CasualShirts"), #imageLiteral(resourceName: "Socks"), #imageLiteral(resourceName: "Belts"), #imageLiteral(resourceName: "Pants"), #imageLiteral(resourceName: "Shorts"), #imageLiteral(resourceName: "Sweaters"), #imageLiteral(resourceName: "Athletic"), #imageLiteral(resourceName: "Ties"), #imageLiteral(resourceName: "Underwear"), #imageLiteral(resourceName: "Hats"), #imageLiteral(resourceName: "Suits"), #imageLiteral(resourceName: "Vests"), #imageLiteral(resourceName: "Jackets"), #imageLiteral(resourceName: "Shoes")]

    let categoryCollection = [ClothingCategory.mensTees, .mensFormal, .mensCasual, .mensSocks, .mensBelts, .mensPants, .mensShorts, .mensSweaters, .mensAthleticShirts, .mensTies, .mensUnderwear, .mensHats, .mensSuits, .mensVests, .mensJackets, .mensShoes]

    let colorCollection = [UIColor.brown , .orange, .yellow, .red, .purple, .blue, .green, .gray, .white, .black, .pink, .gold, .silver, .beige]
}

extension UIColor {
    class var pink: UIColor {
        return UIColor(red: 255/255, green: 111/255, blue: 207/255, alpha: 1)
    }

    class var gold: UIColor {
        return UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1)
    }

    class var silver: UIColor {
        return UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
    }

    class var beige: UIColor {
        return UIColor(red: 245/255, green: 245/255, blue: 220/255, alpha: 1)
    }
}
