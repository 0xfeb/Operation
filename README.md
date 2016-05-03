# 使用操作队列进行网络请求的例子

##使用方法

```
//建立操作队列
let queue = NSOperationQueue()


//操作方法(使用链式方法)
queue.addMethod(...).response(...)

//例子:依次读取各个网站并且获得内容填入
//说明, 为简单起见, 未加异常处理
queue.addMethod {
        //获取文本格式例子
        try! String(contentsOfURL: NSURL(string: "http://www.baidu.com/")!)
    }.response {
        self.contentText.text = $0
    }.addMethod {
        //获取JSON格式例子
        try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: NSURL(string: "http://www.weather.com.cn/data/sk/101010100.html")!)!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
    }.response{
        self.tempText.text = $0?["weatherinfo"]?["temp"] as? String
    }.addMethod {
        //获取图片格式例子
        UIImage(data: NSData(contentsOfURL: NSURL(string: "http://image.wangchao.net.cn/small/product/1280556179293.jpg")!)!)
    }.response{
        self.imageView.image = $0
}

//其它地方与标准的队列一致
queue.suspended = true			//挂起队列
queue.suspended = false 		//恢复队列
queue.cancelAllOperations()		//取消队列
```

##封装

内部的封装非常简单, 基本就十几句话搞定


```
//做一个转接器, 实现柯里化过程, 从而实现链式请求过程
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

//为操作队列扩展一个功能
extension NSOperationQueue {
    func addMethod<T>(method:()->T?) -> CLMethod<T> {
        return CLMethod(queue: self, method: method)
    }
}

```