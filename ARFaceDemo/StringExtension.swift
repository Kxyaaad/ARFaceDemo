//
//  StringExtension.swift
//  ARFaceDemo
//
//  Created by Mac on 2020/6/5.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func image()->UIImage? {
        let size = CGSize(width: 20, height: 22)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(rect)
        
        (self as AnyObject).draw(in: rect, withAttributes: [NSAttributedString.Key.font  : UIFont.systemFont(ofSize: 15)])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
}
