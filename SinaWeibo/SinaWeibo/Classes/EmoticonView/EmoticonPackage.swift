//
//  EmoticonPackge.swift
//  表情键盘界面布局
//
//  Created by 刘勇刚 on 4/4/16.
//  Copyright © 2016 liu. All rights reserved.
//

import UIKit

/*
 结构:
 1. 加载emoticons.plist拿到每组表情的路径
 
 emoticons.plist(字典)  存储了所有组表情的数据
 |----packages(字典数组)
 |-------id(存储了对应组表情对应的文件夹)
 
 2. 根据拿到的路径加载对应组表情的info.plist
 info.plist(字典)
 |----id(当前组表情文件夹的名称)
 |----group_name_cn(组的名称)
 |----emoticons(字典数组, 里面存储了所有表情)
 |----chs(表情对应的文字)
 |----png(表情对应的图片)
 |----code(emoji表情对应的十六进制字符串)
 */

class EmoticonPackage: NSObject {
    /// 当前组表情文件夹的名称
    var id: String?
    /// 组的名称
    var group_name_cn: String?
    /// 当前组所有的表情对象
    var emoticons: [Emoticon]?
    
    /// 获取所有组的表情数组
    // 浪小花 -> 一组  -> 所有的表情模型(emoticons)
    // 默认 -> 一组  -> 所有的表情模型(emoticons)
    // emoji -> 一组  -> 所有的表情模型(emoticons)
    class func loadPackage() -> [EmoticonPackage]? {
        
        var packages = [EmoticonPackage]()
        // 创建最近组
        let pk = EmoticonPackage(id: "")
        pk.group_name_cn = "最近"
        pk.emoticons = [Emoticon]()
        pk.AppendEmptyEmoticons()
        packages.append(pk)
        
        let path = NSBundle.mainBundle().pathForResource("emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
        // 1.加载emoticons.plist
        let dict = NSDictionary(contentsOfFile: path)!
        // 2.获取packages
        let dictArr = dict["packages"] as! [[String: AnyObject]]
        // 3.遍历数组
        for d in dictArr {
            // 4.取出id，创建对应的组
            let package = EmoticonPackage(id: d["id"]! as! String)
            packages.append(package)
            package.loadEmoticon()
            package.AppendEmptyEmoticons()
        }
        
        return packages
        
        
    }
    
     /// 加载每一组对应的表情
    func loadEmoticon() {
        let emoticonDict = NSDictionary(contentsOfFile: infoPath())
        group_name_cn = emoticonDict!["group_name_cn"] as? String
        let dictArr = emoticonDict!["emoticons"] as! [[String: String]]
        emoticons = [Emoticon]()
        var index = 0
        
        for dict in dictArr {
//            emoticons?.append(Emoticon(dict: dict, id: id!))
            if index == 20 {
//                print("添加删除")
                emoticons?.append(Emoticon(isRemoveBtn: true))
                index = 0
            }
            emoticons?.append(Emoticon(dict: dict, id: id!))
            index += 1
        }
        
    }
    /**
     追加空白按钮
     */
    func AppendEmptyEmoticons() {
//        print(emoticons?.count)
        let count = emoticons!.count % 21
        
        for _ in count..<20 {
            // 追加空白按钮
            emoticons?.append(Emoticon(isRemoveBtn: false))
        }
        // 追加一个删除按钮
        emoticons?.append(Emoticon(isRemoveBtn: true))
        
    }
    
    /**
     用户给最近添加表情
     */
    func appendEmoticons(emoticon: Emoticon) {
        // 判断是否为删除按钮
        if emoticon.isRemoveBtn {
            return
        }
        // 判断当前点击的表情是否已经添加过到数组中
        let contains = emoticons!.contains(emoticon)
        if !contains {
            emoticons?.removeLast()
            emoticons?.append(emoticon)
        }
        
        // 对数组排序
        var result = emoticons?.sort({ (e1, e2) -> Bool in
            
            return e1.times > e2.times
        })
        
        // 删除多余的表情
        if !contains {
            result?.removeLast()
            result?.append(Emoticon(isRemoveBtn: true))
        }
        
        emoticons = result
        
    }
    /**
     获取指定文件的全路径
     */
    private func infoPath() ->String {
        
        return (EmoticonPackage.emoticonPath().stringByAppendingPathComponent(id!) as NSString).stringByAppendingPathComponent("info.plist")
    }
    
    /// 获取微博表情的主路径
    class func emoticonPath() -> NSString {
        
        return (NSBundle.mainBundle().bundlePath as NSString).stringByAppendingPathComponent("Emoticons.bundle")
    }
    
    init(id: String)
    {
        self.id = id
    }
    
    

}

class Emoticon: NSObject {
     /// 表情对应的文字
    var chs: String?
     /// 表情对应的图片
    var png: String?
    {
        didSet{
            imagePath = (EmoticonPackage.emoticonPath().stringByAppendingPathComponent(id!) as NSString).stringByAppendingPathComponent(png!)
        }
    }
     /// emoji表情对应的十六进制字符串
    var code: String?
    {
        didSet{
            let scanner = NSScanner(string: code!)
            
            var result: UInt32 = 0
            scanner.scanHexInt(&result)
            
            emojiStr = "\(Character(UnicodeScalar(result)))"
        }
    }
    
    var emojiStr: String?
    
     /// 当前表情对应文件夹
    var id: String?
        /// 表情图片的全路径
    var imagePath: String?
    
    /// 标记是否是删除按钮
    var isRemoveBtn: Bool = false
    // 记录当前表情被使用的次数
    var times: Int = 0
    
    init(isRemoveBtn: Bool) {
        super.init()
        self.isRemoveBtn = isRemoveBtn
    }
    
    
    init(dict: [String: String], id: String)
    {
        super.init()
        self.id = id
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    
    
    
}
