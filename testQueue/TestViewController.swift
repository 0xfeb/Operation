//
//  TestViewController.swift
//  testQueue
//
//  Created by 王渊鸥 on 16/5/3.
//  Copyright © 2016年 王渊鸥. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    let queue = NSOperationQueue()
    @IBOutlet weak var tempText: UITextField!
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 依次读取各个网站并且获得内容填入
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
