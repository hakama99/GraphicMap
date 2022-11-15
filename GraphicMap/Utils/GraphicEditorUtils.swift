//
//  GraphicEditorManager.swift
//  FireBEE
//
//  Created by 陳力維 on 2021/6/3.
//  Copyright © 2021 BLTC Network. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class GraphicEditorUtils:NSObject {
    //縮放大小
    static var ZOOM_MIN_SCALE:CGFloat = 0.4
    static var ZOOM_MAX_SCALE:CGFloat = 1.0
    //基本單位大小
    static var BASE_SIZE:CGSize = CGSize.init(width: 20, height: 20)
    //地圖大小
    @objc static var MAP_SIZE:CGSize = CGSize.init(width: 600, height: 600)
    //物件最小size pixel
    static var MINI_SIZE:CGSize = CGSize.init(width: 100, height: 100)
    //編輯bar高度 pixel
    static var ZONE_EDITOR_SIZE:CGSize = CGSize.init(width: 100, height: 41)
    //裝置編輯bar size pixel
    static var DEVICE_EDITOR_SIZE = CGSize.init(width: 111, height: 57)
    //弧度
    static var DEFAULT_RADIUS:CGFloat = 8
    //預設字型
    static var FONT_NAME:String = "PingFangTC-Regular"
    @objc public static var UPLOAD_LIMIT = 512000
    @objc public class GraphicFrame:NSObject {
        @objc public var x:CGFloat = 0
        @objc public var y:CGFloat = 0
        @objc public var width:CGFloat = 0
        @objc public var height:CGFloat = 0
        
        @objc public var frame:CGRect{
            return CGRect.init(x: x*BASE_SIZE.width, y: y*BASE_SIZE.height, width: width*BASE_SIZE.width, height: height*BASE_SIZE.height)
        }
        
        var point:CGPoint{
            return CGPoint.init(x: x, y: y)
        }
        
        var size:CGSize{
            return CGSize.init(width:width,height:height)
        }
        
        var json:JSON{
            var json = JSON()
            json["x"].doubleValue = (x as NSNumber).doubleValue
            json["y"].doubleValue = (y as NSNumber).doubleValue
            json["width"].doubleValue = (width as NSNumber).doubleValue
            json["height"].doubleValue = (height as NSNumber).doubleValue
            return json
        }

        init(json:JSON) {
            if json["x"].exists(){
                x = CGFloat(truncating: NSNumber.init(value: json["x"].doubleValue))
            }
            if json["y"].exists(){
                y = CGFloat(truncating: NSNumber.init(value: json["y"].doubleValue))
            }
            if json["width"].exists(){
                width = CGFloat(truncating: NSNumber.init(value: json["width"].doubleValue))
            }
            if json["height"].exists(){
                height = CGFloat(truncating: NSNumber.init(value: json["height"].doubleValue))
            }
        }

        init(x:CGFloat,y:CGFloat,width:CGFloat,height:CGFloat) {
            self.x = x
            self.y = y
            self.width = width
            self.height = height
        }
        
        override init() {
            
        }
    }
    
    @objc static var MapSize:[MapModel] = [
        MapModel.init(title: NSLocalizedString("text_map_size_big", comment: ""), size: 800),
        MapModel.init(title: NSLocalizedString("text_map_size_middle", comment: ""), size: 600),
        MapModel.init(title: NSLocalizedString("text_map_size_small", comment: ""), size: 400)
    ]
    
    @objc class MapModel:NSObject{
        @objc var title:String = ""
        @objc var size:Int = 0
        
        init(title:String,size:Int) {
            self.title = title
            self.size = size
        }
    }
    
    @objc public enum MajorType:Int {
        case Zone
        case Device
        case Unknow = -1
    }

    @objc public enum ZoneType:Int {
        case SquareControl
        case CircleControl
        case Square
        case Circle
        case Label
        case Unknow = -1
    }
    
    @objc public enum GraphicDeviceType:Int {
        case Light
        case Beacon
        case Sensor
        case Gateway
        case Repeater
        case Triac
        case Strip
        case DeviceSet
        case Unknow = -1
    }

    //方格背景
    static func BackgroundImage(size:CGSize,lineWidth:CGFloat = 1)->UIImage?{
        let rect = CGRect.init(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext(){
            context.setLineWidth(lineWidth)
            context.setFillColor(UIColor.init(red: 50, green: 52, blue: 60, alpha: 1).cgColor)
            context.setStrokeColor(UIColor.init(red: 66, green: 69, blue: 79, alpha: 1).cgColor)
            
            let shapePath: UIBezierPath = UIBezierPath(rect: rect)
            context.addPath(shapePath.cgPath)
            context.fillPath()
            context.addPath(shapePath.cgPath)
            context.strokePath()
            let image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
    
    static func GetDeviceImage(type:GraphicDeviceType,isSelect:Bool = false,isOn:Bool = false,isOut:Bool = false)->UIImage?{
        let midName = isSelect ? "_select" : "_unselect"
        let lastName = isOn ? "_on" : "_off"
        
        var firstName = ""
        switch type {
        case .Light:
            firstName = "ic_control_light"
        case .Beacon:
            firstName = "ic_control_rc"
        case .Sensor:
            firstName = "ic_control_ml"
        case .Gateway:
            firstName = "ic_control_gw"
        case .Repeater:
            firstName = "ic_control_mr"
        default:
            return nil
        }
        
        var name = ""
        if isOut{
            name = "\(firstName)_out"
        }else{
            if type == GraphicDeviceType.Light{
                name = "\(firstName)\(midName)\(lastName)"
            }else{
                name = "\(firstName)\(midName)"
            }
        }
        return UIImage.init(named: name)
    }
    
    @objc static func ImgPress(image: UIImage?,dataLimit:Int) -> Data?{
        guard let img = image else {
            return nil
        }
        
        let limit = 2000
        let width = img.size.width
        let height = img.size.height
        let scale = width/height
        var sizeChange = CGSize()
        
        var pressData = img.jpegData(compressionQuality: 0.7)
        
        if width <= CGFloat(limit),height<=CGFloat(limit) { //圖片寬度小於時圖片尺寸保持不變,不改變圖片大小
            
        }else{
            if(scale >= 1){
                let changedWidth:CGFloat = 2000
                let changedheight:CGFloat = height / width * 2000
                sizeChange = CGSize(width: changedWidth, height: changedheight)
            }
            else{
                let changedWidth:CGFloat = width / height * 2000
                let changedheight:CGFloat = 2000
                sizeChange = CGSize(width: changedWidth, height: changedheight)
            }
            
            
            
            UIGraphicsBeginImageContext(sizeChange)
            img.draw(in: CGRect(x: 0, y: 0, width: sizeChange.width, height: sizeChange.height))
            let resizedImg = UIGraphicsGetImageFromCurrentImageContext()
              UIGraphicsEndImageContext()

            pressData = resizedImg!.jpegData(compressionQuality: 1)
        }
        

        if pressData!.count > dataLimit{
            pressData = img.jpegData(compressionQuality: 0.5)
        }
        if pressData!.count > dataLimit{
            pressData = img.jpegData(compressionQuality: 0.3)
        }
        if pressData!.count > dataLimit{
            pressData = img.jpegData(compressionQuality: 0.2)
        }

        if pressData!.count > dataLimit{
            return nil
        }else{
            return pressData!
        }
    }
}


extension UIImage {
    /**
     *  重设图片大小
     */
    @objc func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
}

extension UIView{
    @IBInspectable var viewCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
        
    }
    
    @IBInspectable var viewBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }}
    
    @IBInspectable var viewBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @objc func customCorners(corners: CACornerMask, radius: CGFloat){
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }
    
    func customCorners(corners: CACornerMask, radius: CGFloat, bounds: Bool? = nil){
        if bounds != nil{
            clipsToBounds = bounds!
        }
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }
    
    @objc var x : CGFloat {
        get {
            return frame.origin.x
        }
        set {
            var tempFrame : CGRect = frame
            tempFrame.origin.x = newValue
            frame = tempFrame
        }
    }
    
    @objc var y : CGFloat {
        get {
            return frame.origin.y
        }
        set {
            var tempFrame : CGRect = frame
            tempFrame.origin.y = newValue
            frame = tempFrame
        }
    }
    
    @objc var width : CGFloat {
        get {
            return frame.size.width
        }
        set {
            var tempFrame : CGRect = frame
            tempFrame.size.width = newValue
            frame = tempFrame
        }
    }
    
    @objc var height : CGFloat {
        get {
            return frame.size.height
        }
        set {
            var tempFrame : CGRect = frame
            tempFrame.size.height = newValue
            frame = tempFrame
        }
    }
    
    @objc var centerX : CGFloat {
        get {
            return center.x
        }
        set {
            var tempCenter : CGPoint = center
            tempCenter.x = newValue
            center = tempCenter
        }
    }
    @objc var centerY : CGFloat {
        get {
            return center.y
        }
        set {
            var tempCenter : CGPoint = center
            tempCenter.y = newValue
            center = tempCenter
        }
    }
    @objc var size : CGSize {
        get {
            return frame.size
        }
        set {
            var tempFrame : CGRect = frame
            tempFrame.size = newValue
            frame = tempFrame
        }
    }
    
    var right : CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set {
            var tempFrame : CGRect = frame
            tempFrame.origin.x = newValue - frame.size.width
            frame = tempFrame
        }
    }
    
    var bottom : CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set {
            var tempFrame : CGRect = frame
            tempFrame.origin.y = newValue - frame.size.height
            frame = tempFrame
        }
    }
    
    func getAbsolutePosition()->CGPoint{
        var point=self.frame.origin
        
        if let parent = self.superview{
            let parentPoint=parent.getAbsolutePosition()
            point = CGPoint(x:point.x+parentPoint.x,y:point.y+parentPoint.y)
        }
        return point
    }
    
    func drawDashLine(pointA : CGPoint ,pointB : CGPoint,lineColor : UIColor){
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = self.bounds
//        只要是CALayer这种类型,他的anchorPoint默认都是(0.5,0.5)
        shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
//        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.strokeColor = lineColor.cgColor

        shapeLayer.lineWidth = self.frame.size.height
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round

        shapeLayer.lineDashPattern = [NSNumber(value: 2),NSNumber(value: 2)]

        let path = CGMutablePath()
        path.move(to: pointA)
        path.addLine(to: pointB)

        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
}

extension UIButton {
    
    func centerVertically(padding: CGFloat = 6.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
            return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }
    
    func Horital(padding: CGFloat = 6.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
            return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }
}

extension CGSize{
    func add(size:CGSize) -> CGSize{
        return CGSize.init(width: self.width + size.width, height: self.height + size.height)
    }
    
    func multiply(size:CGSize) -> CGSize{
        return CGSize.init(width: self.width * size.width, height: self.height * size.height)
    }
}

extension CGPoint{
    func add(point:CGPoint) -> CGPoint{
        return CGPoint.init(x: self.x + point.x, y: self.y + point.y)
    }
    
    func reduce(point:CGPoint) -> CGPoint{
        return CGPoint.init(x: self.x - point.x, y: self.y - point.y)
    }
    
    func add(size:CGSize) -> CGPoint{
        return CGPoint.init(x: self.x + size.width, y: self.y + size.height)
    }
    
    func multiply(size:CGSize) -> CGPoint{
        return CGPoint.init(x: self.x * size.width, y: self.y * size.height)
    }
}
extension UITextField{
    //設定左方icon
    func setLeftIcon(_ icon: UIImage,_ padding:Int,_ size:Int){
        let outerView = UIView(frame:CGRect(x: 0,y: 0,width: size+padding,height: size))
        let iconView = UIImageView(frame: CGRect(x: padding,y: 0,width: size,height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        leftView = outerView
        leftViewMode = .always
    }
    //清除左方icon
    func unsetLeftIcon(){
        leftView = nil
        leftViewMode = .never
    }
    //設定右方icon
    func setRightIcon(_ icon: UIImage,_ padding:Int,_ size:Int){
        let outerView = UIView(frame:CGRect(x: 0,y: 0,width: size+padding,height: size))
        let iconView = UIImageView(frame: CGRect(x: padding,y: 0,width: size,height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        rightView = outerView
        rightViewMode = .always
    }
    //清除右方icon
    func unsetRightIcon(){
        rightView = nil
        rightViewMode = .never
    }
    //設定下方底線
    func setButtomBorder(color: CGColor, backgroundColor: CGColor = UIColor.white.cgColor){
        self.borderStyle = .none
        self.layer.backgroundColor = backgroundColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = color
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    ///placeholder color
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    @IBInspectable var textFieldCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }}
    
    @IBInspectable var textFieldBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }}
    
    @IBInspectable var textFieldBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    @IBInspectable var paddingLeftCustom: CGFloat {
        get {
            return leftView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }
    
    @IBInspectable var paddingRightCustom: CGFloat {
        get {
            return rightView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            rightView = paddingView
            rightViewMode = .always
        }
    }
}
extension String{
    func replace2(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    //16進位字串轉10進位Int
    func strHex2Int() -> Int
    {
        if !self.isEmpty && self.count>0,let int = Int(self.replace2(target: "#", withString: ""), radix: 16){
            return int
        }
        else{
            return 0
        }
    }
    
    //rgb格式轉int
    func PersonalRgb2Int()->Int{
        let int = self.replace2(target: "#",withString: "").strHex2Int()
        return int - 0xFFFFFF - 1
    }
    
    func IntValue() -> Int
    {
        if !self.isEmpty,
            self.count>0,
            let int = Int(self, radix: 10){
            return int
        }
        else{
            return 0
        }
    }
    
    
    var isInt: Bool {
        return Int(self) != nil
    }
    
    public func substring(from index: Int) -> String {
        if !self.isEmpty && index>=0 && self.count > index {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[startIndex..<self.endIndex]
            
            return String(subString)
        } else {
            return self
        }
    }
    
    public func substring(from index: Int,count:Int) -> String {
        if !self.isEmpty && index>=0 && count>0 && self.count > index {
            if self.count > index+count{
                let startIndex = self.index(self.startIndex, offsetBy: index)
                let endIndex = self.index(self.startIndex, offsetBy: index+count)
                let subString = self[startIndex..<endIndex]
                
                return String(subString)
            }else{
                let startIndex = self.index(self.startIndex, offsetBy: index)
                let subString = self[startIndex..<self.endIndex]
                return String(subString)
            }
        } else {
            return self
        }
    }
    
    func urlEncoded()->String{
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    func urlDecoded()->String{
        return self.removingPercentEncoding ?? ""
    }

    func index(of char: Character) -> Int?{
        let index = self.firstIndex(of: char)
        if index != nil{
            return self.distance(from: startIndex, to: index!)
        }
        return nil
    }
    
    func toAttr()->NSMutableAttributedString{
        return NSMutableAttributedString.init(string: self)
    }
    
    func textSize(font:UIFont,width:CGFloat=0)->CGSize
    {
        let label:UILabel=UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT)))
        label.numberOfLines=width==0 ? 1 : 0
        label.lineBreakMode=NSLineBreakMode.byWordWrapping
        label.font=font
        label.text=self
        label.sizeToFit()
        
        return label.frame.size
    }
    
    func weekDay()->Int?{
        if Calendar.current.shortWeekdaySymbols.contains(self){
            return Calendar.current.shortWeekdaySymbols.firstIndex(of: self)
        }
        if Calendar.current.weekdaySymbols.contains(self){
            return Calendar.current.weekdaySymbols.firstIndex(of: self)
        }
        return nil
    }
    
    func toDate(format:String = "yyyy/MM/dd HH:mm:ss")->Date?{
        let dateFormatter=DateFormatter()
        dateFormatter.dateFormat=format
        if self.isEmpty{
            return nil
        }else if let tmpDate = dateFormatter.date(from: self){
            return tmpDate
        }else{
            return nil
        }
    }
    
    func UnicodeCount()->Int{
        var count = 0
        for unitcode in self.utf16{
            if(unitcode >= 0x0020 && unitcode <= 0x007f) {
                count += 1
            }
            else if(unitcode >= 0xff61 && unitcode <= 0xff90) {
                count += 1
            }else{
                count += 2
            }
        }
        return count
    }
    
    func SubStringByUnitCodeCount(max:Int)->String{
        var count = 0
        var result = ""
        for char in self{
            if(char.utf16.first! >= 0x0020 && char.utf16.first! <= 0x007f) {
                count += 1
            }
            else if(char.utf16.first! >= 0xff61 && char.utf16.first! <= 0xff90) {
                count += 1
            }else{
                count += 2
            }
            if count > max{
                break
            }else{
                result += String.init(char)
            }
        }
        return result
    }
}

extension UIViewController{
    @objc var className:String{
        return String.init(describing:  type(of: self))
    }
    
    @objc static var className:String{
        return String.init(describing: self)
    }
}

extension UIView{
    @objc var className:String{
        return String.init(describing:  type(of: self))
    }
    
    @objc static var className:String{
        return String.init(describing: self)
    }
}

extension NSMutableAttributedString{
    func foreColor(color:UIColor)->NSMutableAttributedString{
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: self.allRange())
        return self
    }
    func backColor(color:UIColor)->NSMutableAttributedString{
        self.addAttribute(NSAttributedString.Key.backgroundColor, value: color, range: self.allRange())
        return self
    }
    func font(font:UIFont)->NSMutableAttributedString{
        self.addAttribute(NSAttributedString.Key.font, value: font, range: self.allRange())
        return self
    }
    func underline()->NSMutableAttributedString{
        self.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: self.allRange())
        return self
    }
    func align(align:NSTextAlignment)->NSMutableAttributedString{
        let para = NSMutableParagraphStyle.init()
        para.alignment = align
        self.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: self.allRange())
        return self
    }
    func spaceing(spacing:CGFloat)->NSMutableAttributedString{
        let para = NSMutableParagraphStyle.init()
        para.lineSpacing = spacing
        self.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: self.allRange())
        return self
    }
    func paragraphStyle(para:NSMutableParagraphStyle)->NSMutableAttributedString{
        self.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: self.allRange())
        return self
    }
    func baseLineOffset(offset:CGFloat)->NSMutableAttributedString{
        self.addAttribute(NSAttributedString.Key.baselineOffset, value: offset, range: self.allRange())
        return self
    }
    func allRange()->NSRange{
        return NSMakeRange(0, self.length)
    }
}

extension UIColor{
    convenience init(red: Int, green: Int, blue: Int, alpha:CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}

@objc extension UIColor{
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    
    //int to rgb
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    
    convenience init(hex: String) {
        let str = hex.replace2(target: "#",withString: "")
        
        let r = str.substring(from: 0,count: 2).strHex2Int()
        let g = str.substring(from: 2,count: 2).strHex2Int()
        let b = str.substring(from: 4,count: 2).strHex2Int()
         //let str = hex.replace2(target: "#",withString: "0x")
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }
    
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
         
        let multiplier = CGFloat(255.999999)
         
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
         
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        }
        else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
    
    var r: Int {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
         
        let multiplier = CGFloat(255.999999)
         
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return 0
        }
         
        return Int(red * multiplier)
    }
    
    var g: Int {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
         
        let multiplier = CGFloat(255.999999)
         
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return 0
        }
         
        return Int(green * multiplier)
    }
    
    var b: Int {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
         
        let multiplier = CGFloat(255.999999)
         
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return 0
        }
         
        return Int(blue * multiplier)
    }
    
    var rgb: Int {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
         
        let multiplier = CGFloat(255.999999)
         
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return 0
        }
         
        return Int(red * multiplier) * 256 * 256 + Int(green * multiplier) * 256 + Int(blue * multiplier)
    }
}

extension GraphicMap{
    func exportData()->JSON{
        let zones = self.deviceList
        var tempData = JSON.init([])
        for zone in zones{
            var zData = zone.gFrame.json
            if let z = zone as? GraphicBaseZone{
                zData["major_type"].intValue = z.MajorType.rawValue
                zData["minor_type"].intValue = z.MinorType.rawValue
                zData["name"].stringValue = z.Name
                zData["devices"] = z.exportData()
            }else if let d = zone as? GraphicBaseDevice{
                zData["major_type"].intValue = d.MajorType.rawValue
                zData["minor_type"].intValue = d.MinorType.rawValue
                zData["name"].stringValue = d.Name
            }
            tempData.arrayObject?.append(zData)
        }
        return tempData
    }
    
    
    func importData(json:JSON?){
        Clean()
        if let arr = json?.array{
            for zoneData in arr{
                createObj(data: zoneData)
            }
        }
    }
    
    func createObj(data:JSON){
        if data["major_type"].exists(),data["minor_type"].exists(){
            let major_type = data["major_type"].intValue
            let minor_type = data["minor_type"].intValue
            switch GraphicEditorUtils.MajorType.init(rawValue: major_type) {
            case .Zone:
                let zone = AddZone(type: .init(rawValue: minor_type) ?? .Unknow, gframe: .init(json: data))
                zone.Name = data["name"].exists() ? data["name"].stringValue : ""
                if data["devices"].exists(),let deviceArr = data["devices"].array{
                    for deviceData in deviceArr{
                        zone.createObj(data: deviceData)
                    }
                }
            case .Device:
                let device = AddDevice(type: .init(rawValue: minor_type) ?? .Unknow, gframe: .init(json: data))
                device.Name = data["name"].exists() ? data["name"].stringValue : ""
            default:
                break
            }
        }
    }
}


extension GraphicBaseZone{
    func createObj(data:JSON){
        if data["major_type"].exists(),data["minor_type"].exists(){
            let major_type = data["major_type"].intValue
            let minor_type = data["minor_type"].intValue
            switch GraphicEditorUtils.MajorType.init(rawValue: major_type) {
            case .Zone:
                let zone = AddZone(type: .init(rawValue: minor_type) ?? .Unknow, gframe: .init(json: data))
                zone.Name = data["name"].exists() ? data["name"].stringValue : ""
                if data["devices"].exists(),let deviceArr = data["devices"].array{
                    for deviceData in deviceArr{
                        zone.createObj(data: deviceData)
                    }
                }
            case .Device:
                let device = AddDevice(type: .init(rawValue: minor_type) ?? .Unknow, gframe: .init(json: data))
                device.Name = data["name"].exists() ? data["name"].stringValue : ""
            default:
                break
            }
        }
    }
    
    func exportData()->JSON{
        var tempData = JSON.init([])
        for zone in self.deviceList{
            var zData = zone.gFrame.json
            if let z = zone as? GraphicBaseZone{
                zData["major_type"].intValue = z.MajorType.rawValue
                zData["minor_type"].intValue = z.MinorType.rawValue
                zData["name"].stringValue = z.Name
                zData["devices"] = z.exportData()
                
            }else if let d = zone as? GraphicBaseDevice{
                zData["major_type"].intValue = d.MajorType.rawValue
                zData["minor_type"].intValue = d.MinorType.rawValue
                zData["name"].stringValue = d.Name
            }
            tempData.arrayObject?.append(zData)
        }
        return tempData
    }
}
