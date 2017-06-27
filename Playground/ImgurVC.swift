//
//  ImgurVC.swift
//  Playground
//
//  Created by Blaine on 6/27/17.
//  Copyright © 2017 Blaine. All rights reserved.
//

import UIKit
import SafariServices

class ImgurVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        deleteImageButton.isHidden = true
        viewImageButton.isHidden = true
    }

    // MARK: - Actions

    @IBAction func showPhotoLibrary(_ sender: UIBarButtonItem) {
        let controller = UIImagePickerController()
        controller.popoverPresentationController?.barButtonItem = sender
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    @IBAction func uploadPhoto(_ sender: UIButton) {
        spinner.startAnimating()
        sender.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false

        guard let image = imageView.image else {
            return
        }

        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let base64Image =  imageData?.base64EncodedData(options: .lineLength64Characters)
        let url = URL(string: "https://api.imgur.com/3/upload")

        var request = URLRequest(url: url!)
        request.setValue("Client-ID fed1a2cc1783370", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = base64Image

        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in

            if let data = data {

                do {
                    guard let operationDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        return
                    }

                    OperationQueue.main.addOperation({
                        self.spinner.stopAnimating()
                    })

                    guard let dataDict = operationDict["data"] as? [String: Any] else {
                        return
                    }

                    if let imageURLText = dataDict["link"] as? String {
                        self.imageURL = URL(string: imageURLText)
                    }

                    if let imageDeleteHash = dataDict["deletehash"] as? String {
                        self.imageDeleteHash = imageDeleteHash
                    }

                    guard let successMessage = operationDict["success"] as? NSNumber else {
                        return
                    }

                    OperationQueue.main.addOperation({
                        if Bool(successMessage) == true {
                            self.topTextLabel.text = "Success!\n\nYour image has been uploaded to Imgur! Tap on a button below to continue…"
                            self.uploadButton.isHidden = true
                            self.deleteImageButton.isHidden = false
                            self.viewImageButton.isHidden = false
                        }
                    })
                    
                } catch {

                }
            }
        })

        dataTask.resume()
    }

    @IBAction func viewTheImageOnline(_ sender: Any) {
        guard let imageURL = imageURL else {
            return
        }

        let controller = SFSafariViewController(url: imageURL)
        present(controller, animated: true, completion: nil)
    }

    @IBAction func deleteTheImage(_ sender: Any) {
        guard let imageHash = imageDeleteHash else {
            return
        }

        self.spinner.startAnimating()
        
        let url = URL(string: "https://api.imgur.com/3/image/" + imageHash)

        var request = URLRequest(url: url!)
        request.setValue("Client-ID fed1a2cc1783370", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"

        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in

            if let data = data {
                do {
                    let serverData = try JSONSerialization.jsonObject(with: data, options: [])
                    print("ServerData:\(serverData)")

                    OperationQueue.main.addOperation({
                        self.spinner.stopAnimating()
                        self.topTextLabel.text = "The image has been deleted from Imgur."
                        self.imageView.isHidden = true
                    })

                } catch {

                }
            }
        })

        dataTask.resume()
    }

    // MARK: - BTS

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)

        if imageView.image != nil {
            uploadButton.isEnabled = true
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - Properties

    var imageURL: URL?
    var imageDeleteHash: String?
    @IBOutlet weak var deleteImageButton: UIButton!
    @IBOutlet weak var viewImageButton: UIButton!
    @IBOutlet weak var topTextLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
}
