//
//  Util.swift
//  Jasy
//
//  Created by User on 12/19/17.
//  Copyright © 2017 administrator. All rights reserved.
//

import UIKit

typealias JDictionary = [String: Any]

enum HTTPMethod {
    case post
    case get
    case put
    case delete
    
    func method() -> String {
        switch self {
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        default:
            return "GET"
        }
    }
}

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

func runIn(seconds: Double, callback: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        callback()
    }
}

class Util {
    
    class func showAlert(for message: String, in viewController: UIViewController) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    class func prepareForJsonBody(_ dictionary: JDictionary) -> Data? {
        let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        return jsonData
    }
    
    class func openURL(with string: String) {
        //from https://stackoverflow.com/a/39546889
        guard let url = URL(string: string) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    class func downloadImageFrom(link: String, callback: ((Data) -> Void)? = nil) {
        
        guard let url = URL(string: link) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil
            
                else { return }
            
            
            callback?(data)
            
        }.resume()
    }
}



extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

//from: https://stackoverflow.com/a/27712427
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit, callback: ((UIImage) -> Void)? = nil) {
        contentMode = mode
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            performUIUpdatesOnMain {
                self.image = image
                callback?(image)
            }
            
        }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit, callback: ((UIImage) -> Void)? = nil) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode, callback: callback)
    }
}


