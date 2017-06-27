//
//  OCRVC.swift
//  Playground
//
//  Created by Blaine on 6/27/17.
//  Copyright © 2017 Blaine. All rights reserved.
//

import UIKit

class OCRVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Actions

    @IBAction func showPhotoLibrary(_ sender: UIBarButtonItem) {
        let controller = UIImagePickerController()
        controller.popoverPresentationController?.barButtonItem = sender
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    // MARK: - OCR

    func performOCR(on image: UIImage) {
        spinner.startAnimating()
        let urlRequest = setupRequest(with: image)
        let dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: {
            data, response, error in

            OperationQueue.main.addOperation({
                self.spinner.stopAnimating()
            })

            if let error = error {
                print("Error:\(error)")
            }
            if let response = response {
                print("response:\(response)")
            }

            guard let data = data else {
                return
            }

            do {
                if let serverData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {

                    OperationQueue().addOperation({
                        self.breakDownTheData(serverData: serverData)
                    })
                }

            } catch {
                
            }
        })
        dataTask.resume()
    }

    // MARK: - BTS

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)

        if let image = imageView.image {
            performOCR(on: image)
        }
    }

    func breakDownTheData(serverData: [String: Any]) {
        guard let firstItemValue = serverData.first?.value as? [Any] else {
            return
        }

        guard let dataDict = firstItemValue.first as? NSDictionary else {
            return
        }

        guard let textDict = dataDict["fullTextAnnotation"] as? NSDictionary else {
            return
        }

        guard let text = textDict["text"] as? String else {
            return
        }

        OperationQueue.main.addOperation({
            self.resultsLabel.text = text
        })
    }

    func setupRequest(with image: UIImage) -> URLRequest {
        let imageBase64 = image.base64EncodeImage()
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")

        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "TEXT_DETECTION"
                    ]
                ]
            ]
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: jsonRequest, options: [])
            request.httpBody = data

        } catch {
            
        }

        return request
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - Properties

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    var googleAPIKey = "AIzaSyA1Uvi_SSDx6IiEJGTzW41WwW781egI8oY"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
}

extension UIImage {
    func base64EncodeImage() -> String? {
        guard var imagedata = UIImagePNGRepresentation(self) else {
            return nil
        }

        // Resize the image if it exceeds the API limit
        if (imagedata.count > 2097152) {
            let oldSize: CGSize = size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize)
        }

        return imagedata.base64EncodedString(options: .endLineWithCarriageReturn)
    }

    func resizeImage(_ imageSize: CGSize) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}
