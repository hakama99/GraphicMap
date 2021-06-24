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
    var MINI_SIZE:CGSize{
        if deviceList.count == 0{
            return CGSize.init(width: 100, height: 100)
        }else{
            let rect = getDeviceRect()
            return CGSize.init(width: rect.width * GraphicEditorUtils.BASE_SIZE.width, height: rect.height * GraphicEditorUtils.BASE_SIZE.height)
        }
    }
    //選擇顏色
    var SELECT_COLOR = UIColor.init(red: 240, green: 91, blue: 40, alpha: 1)
    var DEFAULT_COLOR = UIColor.init(red: 66, green: 69, blue: 79, alpha: 0.4)
    //縮放按鈕
    var INSTRUCTION_COLOR = UIColor.init(red: 255, green: 181, blue: 115, alpha: 1)
    var instructionSize:CGSize = CGSize.init(width: 40, height: 40)
    //類型
    var MajorType:GraphicEditorUtils.MajorType{
        return .Zone
    }
    //類型
    var MinorType:GraphicEditorUtils.ZoneType{
        return .Unknow
    }
    
    //UI
    
    //物件清單
    var deviceList:[GraphicBaseDevice] = []
    var DeviceList:[GraphicBaseDevice]{
        return deviceList
    }
    //存放子物件
    var zone:UIView!
    //縮放按鈕
    var instruction:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func initialize() {
        deviceList = []
        self.backgroundColor = .clear
        
        zone = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: frame.width, height: frame.height)))
        zone.backgroundColor = DEFAULT_COLOR
        zone.clipsToBounds = true
        zone.isUserInteractionEnabled = false
        self.addSubview(zone)
        
        instruction = UIImageView.init(frame: CGRect.init(x: frame.width-instructionSize.width, y: 0, width: instructionSize.width, height: instructionSize.height))
        instruction.image = UIImage.init(named: "ic_control_zone_select_on")?.reSizeImage(reSize: CGSize.init(width: 20, height: 20))
        instruction.isHidden = true
        instruction.isUserInteractionEnabled = true
        self.addSubview(instruction)
        
        let gerture = UIPanGestureRecognizer(target:self,action:#selector(gestureResize(recognizer:)))
        instruction.addGestureRecognizer(gerture)
        
        let tap = UIPanGestureRecognizer.init(target: self, action: #selector(gestureMove(recognizer:)))
        self.addGestureRecognizer(tap)
    }
    
    override func SetFocus(isSelect:Bool){
        super.SetFocus(isSelect: isSelect)
        
        if self.isSelect{
            zone?.backgroundColor = SELECT_COLOR
            
            instruction?.isHidden = false
        }else{
            zone?.backgroundColor = DEFAULT_COLOR
            
            instruction?.isHidden = true
        }
    }

    //zoom縮放
    override func Scale(scale: CGFloat) {
        super.Scale(scale: scale)
    }
    
    //物件調整size
    override func Resize(toSize: CGSize) {
        let resize = CGSize.init(width: max(toSize.width, MINI_SIZE.width), height: max(toSize.height, MINI_SIZE.height))
        self.frame = CGRect.init(x: x - (resize.width - size.width)/2 , y: y - (resize.height - size.height)/2, width: resize.width, height: resize.height)
        gFrame = getGFrame()
        
        zone.frame = CGRect.init(origin: .zero, size: resize)
        
        
        instruction.frame = CGRect.init(x: frame.width-instructionSize.width, y: 0, width: instructionSize.width, height: instructionSize.height)
        
        reloadPositionInZone()
    }
    
    //加入單一裝置
    func AddDevice(type:GraphicEditorUtils.DeviceType,gframe:GraphicEditorUtils.GraphicFrame)->GraphicBaseDevice{
        
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
        default:
            device = GraphicBaseDevice.init(frame: gframe.frame)
            break
        }
        device.gFrame = gframe
        device.gFrame.width = device.DEFAULT_SIZE.width
        device.gFrame.height = device.DEFAULT_SIZE.height
        device.SetEditorEnable(bo: false)
        device.Scale(scale: scale)
        zone.addSubview(device)
        deviceList.append(device)
        reloadPositionInZone()
        return device
    }
    
    //加入多裝置 gframe大小控制裝置排列
    func AddDevice(types:[GraphicEditorUtils.DeviceType],gframe:GraphicEditorUtils.GraphicFrame)->[GraphicBaseDevice]{
        
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
            zone.addSubview(device)
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
           let view = recognizer.view,
           let parent = self.superview{
            //print(view.frame)
            //print(self.frame)
            //1、手势在self.view坐标系中移动的位置
            let translation = recognizer.translation(in: parent)
            //print(translation)
            //起始
            var newCenter = CGPoint.init(x: view.x + translation.x, y: view.y + translation.y)

            
            //2、限制屏幕范围：
            let minY:CGFloat = 0
            let maxY:CGFloat = parent.height / scale - gHeight
            let minX:CGFloat = 0
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
            
            
            view.frame.origin = newCenter
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
            item.frame = CGRect.init(origin: zone.center.add(point: item.gFrame.frame.origin), size: item.gFrame.frame.size)
        }
    }
    
    func Clean(){
        for item in deviceList{
            item.removeFromSuperview()
        }
        deviceList = []
    }
}
