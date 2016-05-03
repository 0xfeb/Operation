//
//  CLRequest.swift
//  testQueue
//
//  Created by 王渊鸥 on 16/5/3.
//  Copyright © 2016年 王渊鸥. All rights reserved.
//

import Foundation
import UIKit

class CLRequest {
    var session:NSURLSession
    var request:NSURLRequest
    
    init(session:NSURLSession, request:NSURLRequest) {
        self.session = session
        self.request = request
    }
    
    func jsonArrayResponse(response:([AnyObject]?)->()) -> NSURLSession {
        session.dataTaskWithRequest(request) { (data, resp, error) in
            if let data = data {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    if json is [AnyObject] {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            response(json as? [AnyObject])
                        })
                    } else {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            response(nil)
                        })
                    }
                } catch _ {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        response(nil)
                    })
                }
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    response(nil)
                })
            }
            }.resume()
        return session
    }
    
    func jsonDictResponse(response:([String:AnyObject]?)->()) -> NSURLSession {
        session.dataTaskWithRequest(request) { (data, resp, error) in
            if let data = data {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    if json is [String:AnyObject] {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            response(json as? [String:AnyObject])
                        })
                    } else {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            response(nil)
                        })
                    }
                } catch _ {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        response(nil)
                    })
                }
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    response(nil)
                })
            }
            }.resume()
        return session
    }
    
    func stringResponse(response:(String?)->()) -> NSURLSession {
        session.dataTaskWithRequest(request) { (data, resp, error) in
            if let data = data {
                let text = NSString(data: data, encoding: NSUTF8StringEncoding)
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    response(text as? String)
                })
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    response(nil)
                })
            }
            }.resume()
        return session
    }
    
    func dataResponse(response:(NSData?)->()) -> NSURLSession {
        session.dataTaskWithRequest(request) { (data, resp, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                response(data)
            })
            }.resume()
        return session
    }
    
    func imageReponse(response:(UIImage?)->()) -> NSURLSession {
        session.dataTaskWithRequest(request) { (data, resp, error) in
            if let data = data {
                let image = UIImage(data: data)
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    response(image)
                })
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    response(nil)
                })
            }
            }.resume()
        return session
    }
}


extension NSURLSession {
    func POST(url:String, _ parameters:[String:String] = [:]) -> CLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 120)
        request.HTTPMethod = "POST"
        request.HTTPBody = NSData.setting {
            let param = $0
            parameters.forEach{ param.set($0.0, value: $0.1) }
        }
        return CLRequest(session: self, request: request)
    }
    
    func GET(url:String, _ parameters:[String:String] = [:]) -> CLRequest {
        let urlParam = parameters.reduce(url+"?") { $0+$1.0+":"+$1.1+"&" }
        let request = NSMutableURLRequest(URL: NSURL(string: urlParam)!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 120)
        request.HTTPMethod = "GET"
        return CLRequest(session: self, request: request)
    }
    
    func DELETE(url:String, _ parameters:[String:String] = [:]) -> CLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 120)
        request.HTTPMethod = "DELETE"
        request.HTTPBody = NSData.setting {
            let param = $0
            parameters.forEach{ param.set($0.0, value: $0.1) }
        }
        return CLRequest(session: self, request: request)
    }
    
    func OPTION(url:String, _ parameters:[String:String] = [:]) -> CLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 120)
        request.HTTPMethod = "OPTION"
        request.HTTPBody = NSData.setting {
            let param = $0
            parameters.forEach{ param.set($0.0, value: $0.1) }
        }
        return CLRequest(session: self, request: request)
    }
}

class CLRequestClient {
    var session:NSURLSession
    static var baseURL = ""
    static var shareParameters:[String:String] = [:]
    
    init(session:NSURLSession) {
        self.session = session
    }
    
    func getParameters(parameters:[String:String]) -> [String:String] {
        var param = parameters
        CLRequestClient.shareParameters.forEach{ param[$0.0] = $0.1 }
        return param
    }
    
    func getURL(url:String) -> String {
        let urlGap = CLRequestClient.baseURL.isEmpty||CLRequestClient.baseURL.hasSuffix("/") ? "" : "/"
        return CLRequestClient.baseURL + urlGap + url
    }
    
    func POST(url:String, _ parameters:[String:String] = [:]) -> CLRequest {
        return session.POST(getURL(url), getParameters(parameters))
    }
    
    func GET(url:String, _ parameters:[String:String] = [:]) -> CLRequest {
        return session.GET(getURL(url), getParameters(parameters))
    }
    
    func DELETE(url:String, _ parameters:[String:String] = [:]) -> CLRequest {
        return session.DELETE(getURL(url), getParameters(parameters))
    }
    
    func OPTION(url:String, _ parameters:[String:String] = [:]) -> CLRequest {
        return session.OPTION(getURL(url), getParameters(parameters))
    }
}

extension NSOperationQueue {
    //MARK:Session
    func realTimeSession() -> NSURLSession {
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        return NSURLSession(configuration: config, delegate: nil, delegateQueue: self)
    }
    
    func cacheSession() -> NSURLSession {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config, delegate: nil, delegateQueue: self)
    }

    //MARK:Client
    func realTimeClient() -> CLRequestClient {
        return CLRequestClient(session: realTimeSession())
    }
    
    func cacheClient() -> CLRequestClient {
        return CLRequestClient(session: cacheSession())
    }
    
    static func setClientBaseURL(url:String) {
        CLRequestClient.baseURL = url
    }
    
    static func setClientCommonParameters(parameters:[String:String]) {
        CLRequestClient.shareParameters = parameters
    }
}

