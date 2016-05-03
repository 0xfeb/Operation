//
//  TestViewController.swift
//  testQueue
//
//  Created by 王渊鸥 on 16/5/3.
//  Copyright © 2016年 王渊鸥. All rights reserved.
//

import UIKit
import Photos

class TestViewController: UIViewController {
    let queue = NSOperationQueue()
    @IBOutlet weak var tempText: UITextField!
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //使用同步网络请求封装成异步
        queue.addMethod {
                //获取文本格式
                try! String(contentsOfURL: NSURL(string: "http://www.baidu.com/")!)
            }.response {
                self.contentText.text = $0
            }.addMethod {
                //获取JSON格式
                try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: NSURL(string: "http://www.weather.com.cn/data/sk/101010100.html")!)!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
            }.response{
                self.tempText.text = $0?["weatherinfo"]?["temp"] as? String
            }.addMethod {
                //获取图片格式
                UIImage(data: NSData(contentsOfURL: NSURL(string: "http://image.wangchao.net.cn/small/product/1280556179293.jpg")!)!)
            }.response{
                self.imageView.image = $0
        }
        
        //使用原装的异步网络请求, 也是自己做的封装, 啊~~ 我怎么这么爱造轮子
        queue.cacheSession()
            .GET("http://www.baidu.com/")
            .stringResponse{
                self.contentText.text = $0
            }.GET("http://www.weather.com.cn/data/sk/101010100.html")
            .jsonDictResponse{
                self.tempText.text = $0?["weatherinfo"]?["temp"] as? String
            }.GET("http://image.wangchao.net.cn/small/product/1280556179293.jpg")
            .imageReponse{
                self.imageView.image = $0
        }
        
        //使用Client模式
        //NSOperationQueue.setClientBaseURL("http://www.aaa.com/interface/")
        //NSOperationQueue.setClientCommonParameters(["token":"aaaa"])
        queue.cacheClient()
            .GET("http://www.baidu.com/")
            .stringResponse{
                self.contentText.text = $0
            }.GET("http://www.weather.com.cn/data/sk/101010100.html")
            .jsonDictResponse{
                self.tempText.text = $0?["weatherinfo"]?["temp"] as? String
            }.GET("http://image.wangchao.net.cn/small/product/1280556179293.jpg")
            .imageReponse{
                self.imageView.image = $0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //返回此界面, 继续原先的操作
        queue.suspended = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //跳到其它界面, 挂起自己的操作, 让其它界面的操作先进行
        queue.suspended = true
    }
    
    deinit {
        //如果想批量取消队列, 可以直接cancel掉一批
        queue.cancelAllOperations()
    }
}
