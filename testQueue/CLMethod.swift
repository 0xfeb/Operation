//
//  File.swift
//  testQueue
//
//  Created by 王渊鸥 on 16/5/3.
//  Copyright © 2016年 王渊鸥. All rights reserved.
//

import Foundation

class CLMethod<T> {
    var queue:NSOperationQueue!
    var method:()->T? = { nil }
    
    init(queue:NSOperationQueue, method:()->T?) {
        self.queue = queue
        self.method = method
    }
    
    func response(response:(T?)->()) -> NSOperationQueue {
        queue.addOperationWithBlock {
            let result = self.method()
            NSOperationQueue.mainQueue().addOperationWithBlock({
                response(result)
            })
        }
        return queue
    }
}

extension NSOperationQueue {
    func addMethod<T>(method:()->T?) -> CLMethod<T> {
        return CLMethod(queue: self, method: method)
    }
}
