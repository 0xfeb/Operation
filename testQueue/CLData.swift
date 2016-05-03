//
//  CLData.swift
//  testQueue
//
//  Created by 王渊鸥 on 16/5/3.
//  Copyright © 2016年 王渊鸥. All rights reserved.
//

import Foundation
import UIKit

class CLData {
    var source:NSMutableData
    var boundry:String
    
    init(source:NSMutableData, boundry:String) {
        self.boundry = boundry
        self.source = source
    }
    
    func set(key:String, value:String) -> CLData {
        source.set(key, value: value, boundry: boundry)
        return self
    }
    
    func set(file:String, data:NSData) -> CLData {
        source.set(file, data: data, boundry: boundry)
        return self
    }
    
    func set(file:String, image:UIImage, compose:CGFloat = 1.0) -> CLData {
        var data:NSData? = nil
        if compose == 1.0 {
            data = UIImagePNGRepresentation(image)
        } else {
            data = UIImageJPEGRepresentation(image, compose)
        }
        
        if let data = data {
            source.set(file, data: data, boundry: boundry)
        }
        return self
    }
    
    func setting(action:(CLData)->()) -> NSData {
        action(self)
        source.closeBoundry(boundry)
        
        return NSData(data: source)
    }
}

extension NSData {
    class func parameters(boundry:String = "_COASTLINE_STUDIO_") -> CLData {
        return CLData(source: NSMutableData(), boundry: boundry)
    }
    
    class func setting(action:(CLData)->()) -> NSData {
        let data = NSData.parameters()
        return data.setting(action)
    }
}

extension NSMutableData {
    
    func set(key:String, value:String, boundry:String) {
        let leadString = "\n--\(boundry)"
            + "\nContent-Disposition:form-data;name=\"\(key)\"\n"
            + "\n\(value)"
        
        self.appendData((leadString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    func set(file:String, data:NSData, boundry:String) {
        let leadString = "\n--\(boundry)"
            + "\nContent-Disposition:form-data;name=\"file\";filename=\"\(file)\""
            + "\nContent-Type:application/octet-stream"
            + "\nContent-Transfer-Encoding:binary\n\n"
        
        self.appendData((leadString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        self.appendData(data)
    }
    
    func closeBoundry(boundry:String) {
        let endString = "\n--\(boundry)--"
        self.appendData((endString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
    }
}


func test() {
    NSData.setting{
        $0.set("aaa", value: "bbbb")
        $0.set("ccc", value: "dddd")
    }
}