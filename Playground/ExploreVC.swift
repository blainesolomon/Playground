//
//  ExploreVC.swift
//  Playground
//
//  Created by Blaine on 6/27/17.
//  Copyright © 2017 Blaine. All rights reserved.
//

import UIKit
import SafariServices

class ExploreVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScene()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showMenuFirstTime()
    }

    // MARK: - Actions

    @IBAction func hideMenu(_ sender: Any) {
        hideFilterMenu()
    }

    @IBAction func toggleMenu(_ sender: Any) {
        if menuTopSpace.constant == -self.menuHeight.constant {
            showFilterMenu()
        } else {
            hideFilterMenu()
        }
    }

    // MARK: - Collection

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCollection.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SMCell

        let item = itemCollection[indexPath.item]
        cell.imageView.af_setImage(withURL: item.thumbnailURL)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = itemCollection[indexPath.item]
        let controller = SFSafariViewController(url: selectedItem.webURL)
        present(controller, animated: true, completion: nil)
    }

    // MARK: - BTS

    func setupScene() {
        loadSelectedItems()
        self.menuTopSpace.constant = -self.menuHeight.constant
        self.coverView.alpha = 0
    }

    func showFilterMenu() {
        view.layoutIfNeeded()

        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.menuTopSpace.constant = -10
            self.coverView.alpha = 1
            self.view.layoutIfNeeded()
        })
    }

    func hideFilterMenu() {
        view.layoutIfNeeded()

        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.menuTopSpace.constant = -self.menuHeight.constant
            self.coverView.alpha = 0
            self.view.layoutIfNeeded()
        })
    }

    func loadSelectedItems() {
        itemCollection.removeAll()
        collectionView.reloadData()

        shopStyleController.requestClothing(withColor: selectedColor, category: selectedCategory, completionHandler: { itemCollection in

            self.itemCollection = itemCollection
            self.collectionView.reloadData()
        })
    }

    func showMenuFirstTime() {
        if didShowMenuAtStartup == true {
            return
        }

        didShowMenuAtStartup = true
        showFilterMenu()
    }

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Category" {
            categoryController = segue.destination as! FilterMenuVC
            categoryController.delegate = self
        }

        if segue.identifier == "Color" {
            categoryController = segue.destination as! FilterMenuVC
            categoryController.delegate = self
        }
    }

    // MARK: - Properties

    var didShowMenuAtStartup = false
    var itemCollection = [ClothingItem]()
    var selectedColor = UIColor.red
    var selectedCategory = ClothingCategory.mensShorts

    let shopStyleController = ShopStyleController()
    var categoryController: FilterMenuVC!
    var colorController: FilterMenuVC!

    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var menuTopSpace: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuHeight: NSLayoutConstraint!
}
