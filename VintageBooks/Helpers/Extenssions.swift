//
//  Extenssions.swift
//  VintageBooks
//
//  Created by Bilal Fakhro on 2018-12-05.
//  Copyright © 2018 Bilal Fakhro. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
                //download hit an error so lets return out
                if let error = error {
                    print(error)
                    return
                }
                    DispatchQueue.main.async(execute: {
                        if let downloadedImage = UIImage(data: data!) {
                            imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                            
                            self.image = downloadedImage
                }
            })
        }).resume()
    }
}
