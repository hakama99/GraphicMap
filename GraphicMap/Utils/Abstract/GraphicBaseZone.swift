//
//  Modal.swift
//  ModalView
//
//  Created by Aatish Rajkarnikar on 3/20/17.
//  Copyright © 2017 Aatish. All rights reserved.
//

import Foundation
import UIKit


class GraphicBaseZone: GraphicBaseAbstract {
    
    //zone最小size
    @objc public var MINI_SIZE:CGSize{
        if deviceList.count == 0{
            return GraphicEditorUtils.MINI_SIZE
        }else{
            let rect = getDeviceRect()
            return CGSize.init(width: max(rect.width * GraphicEditorUtils.BASE_SIZE.width, GraphicEditorUtils.MINI_SIZE.width), height: max(rect.height * GraphicEditorUtils.BASE_SIZE.height, GraphicEditorUtils.MINI_SIZE.height))
        }
    }
    //選擇顏色
    var SELECT_COLOR = UIColor.init(red: 240, green: 91, blue: 40, alpha: 1)
    var DEFAULT_COLOR = UIColor.init(red: 66, green: 69, blue: 79, alpha: 0.4)
    //縮放按鈕
    private var INSTRUCTION_COLOR = UIColor.init(red: 255, green: 181, blue: 115, alpha: 1)
    private var instructionSize:CGSize = CGSize.init(width: 30, height: 30)
    //類型
    override var MajorType:GraphicEditorUtils.MajorType{
        return .Zone
    }
    var MinorType:GraphicEditorUtils.ZoneType{
        return .Unknow
    }
    
    //UI
    
    //物件清單
    @objc public  var deviceList:[GraphicBaseAbstract] = []
    //存放子物件
    var zoneView:UIView!
    //縮放按鈕
    var scaleBtn:UIImageView!
    //縮放按鈕
    var moveBtn:UIImageView!
    
    override init(frame: CGRect) {
        let size = CGSize.init(width: max(frame.width, GraphicEditorUtils.MINI_SIZE.width), height: max(frame.height, GraphicEditorUtils.MINI_SIZE.height))
        super.init(frame: CGRect.init(origin: frame.origin, size: size))
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func initialize() {
        deviceList = []
        self.backgroundColor = .clear
        
        zoneView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: frame.width, height: frame.height)))
        zoneView.backgroundColor = DEFAULT_COLOR
        zoneView.clipsToBounds = true
        zoneView.isUserInteractionEnabled = false
        self.addSubview(zoneView)
        
        scaleBtn = UIImageView.init(frame: CGRect.init(x: frame.width, y: -instructionSize.height/scale, width: instructionSize.width/scale, height: instructionSize.height/scale))
        scaleBtn.image = UIImage.init(named: "ic_add_device_scale")?.reSizeImage(reSize: CGSize.init(width: 20, height: 20))
        scaleBtn.isHidden = true
        scaleBtn.isUserInteractionEnabled = true
        self.addSubview(scaleBtn)
        
        let scaleTap = UIPanGestureRecognizer(target:self,action:#selector(gestureResize(recognizer:)))
        scaleBtn.addGestureRecognizer(scaleTap)
        
        
        moveBtn = UIImageView.init(frame: CGRect.init(x: -instructionSize.width/scale, y: -instructionSize.height/scale, width: instructionSize.width/scale, height: instructionSize.height/scale))
        moveBtn.image = UIImage.init(named: "ic_add_device_move")?.reSizeImage(reSize: CGSize.init(width: 20, height: 20))
        moveBtn.isHidden = true
        moveBtn.isUserInteractionEnabled = true
        self.addSubview(moveBtn)
        
        let moveTap = UIPanGestureRecognizer(target:self,action:#selector(gestureMove(recognizer:)))
        moveBtn.addGestureRecognizer(moveTap)
    }
    
    override func SetFocus(isSelect:Bool){
        super.SetFocus(isSelect: isSelect)
        
        if self.isSelect{
            zoneView?.backgroundColor = SELECT_COLOR
            
            scaleBtn?.isHidden = false
            moveBtn?.isHidden = false
        }else{
            zoneView?.backgroundColor = DEFAULT_COLOR
            
            scaleBtn?.isHidden = true
            moveBtn?.isHidden = true
        }
        
        for item in deviceList{
            if let device = item as? GraphicBaseDevice{
                device.SetImage(isSelect: isSelect)
            }else if let zone = item as? GraphicBaseZone{
                zone.SetFocus(isSelect: isSelect)
            }
        }
    }

    //zoom縮放
    override func Scale(scale: CGFloat) {
        super.Scale(scale: scale)
        Resize(toSize: size)
    }
    
    //物件調整size
    override func Resize(toSize: CGSize) {
        let resize = CGSize.init(width: max(toSize.width, MINI_SIZE.width), height: max(toSize.height, MINI_SIZE.height))
        self.frame = CGRect.init(x: x - (resize.width - size.width)/2 , y: y - (resize.height - size.height)/2, width: resize.width, height: resize.height)
        gFrame = getGFrame()
        
        zoneView.frame = CGRect.init(origin: .zero, size: resize)
        
        
        scaleBtn.frame = CGRect.init(x: frame.width, y: -instructionSize.height/scale, width: instructionSize.width/scale, height: instructionSize.height/scale)
        moveBtn.frame = CGRect.init(x: -instructionSize.width/scale, y: -instructionSize.height/scale, width: instructionSize.width/scale, height: instructionSize.height/scale)
        
        reloadPositionInZone()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let scale = self.convert(point, to: scaleBtn)
        if scaleBtn.bounds.contains(scale) {
            return scaleBtn.hitTest(scale, with: event)
        }
        let move = self.convert(point, to: moveBtn)
        if moveBtn.bounds.contains(move) {
            return moveBtn.hitTest(move, with: event)
        }
        let tmp = super.hitTest(point, with: event)
        return tmp
    }
    
    @objc func AddZone(type:GraphicEditorUtils.ZoneType,gframe:GraphicEditorUtils.GraphicFrame)->GraphicBaseZone{
        
        var zone:GraphicBaseZone!
        switch type {
        case .SquareControl:
            zone = GraphicSquareControlZone.init(frame: gframe.frame)
        case .CircleControl:
            zone = GraphicCircleControlZone.init(frame: gframe.frame)
        case .Square:
            zone = GraphicSquareZone.init(frame: gframe.frame)
        case .Circle:
            zone = GraphicCircleZone.init(frame: gframe.frame)
        case .Label:
            zone = GraphicLabelZone.init(frame: gframe.frame)
        default:
            zone = GraphicBaseZone.init(frame: gframe.frame)
        }
        zone.gFrame = gframe
        zone.Scale(scale: scale)
        zoneView.addSubview(zone)
        deviceList.append(zone)
        reloadPositionInZone()
        return zone
    }
    
    //加入單一裝置
    func AddDevice(type:GraphicEditorUtils.GraphicDeviceType,gframe:GraphicEditorUtils.GraphicFrame)->GraphicBaseDevice{
        
        var device:GraphicBaseDevice!
        switch type {
        case .Light:
            device = GraphicLight.init(frame: gframe.frame)
        case .Beacon:
            device = GraphicBeacon.init(frame: gframe.frame)
            break
        case .Sensor:
            device = GraphicSensor.init(frame: gframe.frame)
            break
        case .Gateway:
            device = GraphicGateway.init(frame: gframe.frame)
            break
        case .Repeater:
            device = GraphicRepeater.init(frame: gframe.frame)
            break
        case .Triac:
            device = GraphicTriac.init(frame: gframe.frame)
            break
        case .Strip:
            device = GraphicStrip.init(frame: gframe.frame)
            break
        default:
            device = GraphicBaseDevice.init(frame: gframe.frame)
            break
        }
        device.gFrame = gframe
        device.gFrame.width = device.DEFAULT_SIZE.width
        device.gFrame.height = device.DEFAULT_SIZE.height
        device.SetEditorEnable(bo: false)
        device.Scale(scale: scale)
        device.isInZone = true
        zoneView.addSubview(device)
        deviceList.append(device)
        reloadPositionInZone()
        return device
    }
    
    //加入多裝置 gframe大小控制裝置排列
    func AddDevice(types:[GraphicEditorUtils.GraphicDeviceType],gframe:GraphicEditorUtils.GraphicFrame)->[GraphicBaseDevice]{
        
        var list = [GraphicBaseDevice]()
        for i in 0..<types.count{
            var device:GraphicBaseDevice!
            switch types[i] {
            case .Light:
                device = GraphicLight.init(frame: gframe.frame)
            case .Beacon:
                device = GraphicBeacon.init(frame: gframe.frame)
                break
            case .Sensor:
                device = GraphicSensor.init(frame: gframe.frame)
                break
            case .Gateway:
                device = GraphicGateway.init(frame: gframe.frame)
                break
            case .Repeater:
                device = GraphicRepeater.init(frame: gframe.frame)
                break
            case .Triac:
                device = GraphicTriac.init(frame: gframe.frame)
                break
            case .Strip:
                device = GraphicStrip.init(frame: gframe.frame)
                break
            default:
                device = GraphicBaseDevice.init(frame: gframe.frame)
                break
            }
            let zoneSize = CGSize.init(width: device.gWidth / GraphicEditorUtils.BASE_SIZE.width + 1, height: device.gHeight / GraphicEditorUtils.BASE_SIZE.height + 1)
            //device.gFrame = gframe
            //先設定原點為中心點再移動至grame座標
            var perLine:Int = Int(gframe.width / zoneSize.width)
            perLine = max(perLine, 1)
            let x = CGFloat(i % perLine) * (zoneSize.width)
            let y = CGFloat(i/perLine) * (zoneSize.height)
            let position = GraphicEditorUtils.GraphicFrame.init(x: gframe.x + x , y: gframe.y + y, width: device.DEFAULT_SIZE.width, height: device.DEFAULT_SIZE.height)
            device.gFrame = position
            device.SetEditorEnable(bo: false)
            device.Scale(scale: scale)
            device.isInZone = true
            zoneView.addSubview(device)
            deviceList.append(device)
            list.append(device)
        }
        reloadPositionInZone()
        return list
    }
    
    //觸控滑動
    @objc func gestureMove(recognizer:UIPanGestureRecognizer){
        del?.OnItemDrag(item: self,recognizer:recognizer)
        if isSelect,
           let parent = self.superview{
            //print(view.frame)
            //print(self.frame)
            //1、手势在self.view坐标系中移动的位置
            let translation = recognizer.translation(in: parent)
            //print(translation)
            //起始
            var newCenter = CGPoint.init(x: self.x + translation.x, y: self.y + translation.y)

            
            //2、限制屏幕范围：
            let minY:CGFloat = 0 + instructionSize.height / scale
            let maxY:CGFloat = parent.height / scale - gHeight
            let minX:CGFloat = 0 + instructionSize.width / scale
            let maxX:CGFloat = parent.width / scale - gWidth
            //print("maxx\(maxX)")
            //上边界的限制
            newCenter.y = max(minY, newCenter.y)
            //下边界的限制
            newCenter.y = min(maxY, newCenter.y)
            //左边界的限制
            newCenter.x = max(minX, newCenter.x)
             //右边界的限制
            newCenter.x = min(maxX,newCenter.x)
            //print("newCenter.x\(newCenter.x)")
            //del?.OnItemDrag?(item: self,recognizer:recognizer)
            
            
            self.frame.origin = newCenter
            gFrame = getGFrame()
            
            //3、将手势坐标点归0、否则会累加
            recognizer.setTranslation(CGPoint.zero, in: parent)
        }
    }

    //觸控縮放
    @objc func gestureResize(recognizer:UIPanGestureRecognizer) {
        //print(recognizer.view)
        //print(self.superview                          )
        if isSelect,
           let parent = self.superview{
            //print(view.frame)
            //print(self.frame)
            //1、手势在self.view坐标系中移动的位置
            let translation = recognizer.translation(in: parent)
            //print(translation)
            //起始
            let newSize = CGSize.init(width: self.width + translation.x*2, height: self.height - translation.y*2)

            Resize(toSize: newSize)
            //3、将手势坐标点归0、否则会累加
            recognizer.setTranslation(CGPoint.zero, in: parent)
            del?.OnItemScale(item: self,recognizer:recognizer)
        }
    }
    
    //取得裝置顯示範圍
    final func getDeviceRect()->GraphicEditorUtils.GraphicFrame{
        var minX = deviceList.first?.gFrame.x ?? 0
        var minY = deviceList.first?.gFrame.y ?? 0
        var maxX = (deviceList.first?.gFrame.x ?? 0) + (deviceList.first?.gFrame.width ?? 0)
        var maxY = (deviceList.first?.gFrame.y ?? 0) + (deviceList.first?.gFrame.height ?? 0)
        //print("minX\(minX)")
        //print("minY\(minY)")
        //print("maxX\(maxX)")
        //print("maxY\(maxY)")
        
        //取得所有物件顯示範圍
        for item in deviceList{
            minX = min(minX, item.gFrame.x)
            minY = min(minY, item.gFrame.y)
            maxX = max(maxX, item.gFrame.x + item.gFrame.width)
            maxY = max(maxY, item.gFrame.y + item.gFrame.height)
            
            //print("minX\(minX)")
            //print("minY\(minY)")
            //print("maxX\(maxX)")
            //print("maxY\(maxY)")
        }
        return GraphicEditorUtils.GraphicFrame.init(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    //重新調整裝置內位置
    func reloadPositionInZone(){
        for item in deviceList{
            item.frame = CGRect.init(origin: zoneView.center.add(point: item.gFrame.frame.origin), size: item.gFrame.frame.size)
        }
    }
    
    func Clean(){
        for item in deviceList{
            item.removeFromSuperview()
        }
        deviceList = []
    }
}
