//CheckBox.swift
/*
 * LKCheckbox
 * Created by penumutchu.prasad@gmail.com on 18/04/19
 * is a product created by abnboys
 * For abnboys in the LKCheckbox in the LKCheckbox
 * Here the permission is granted to this file with free of use anywhere in any iOS Projects.
 * Copyright © 2019 abnboys.com. All rights reserved.
*/

import UIKit

class GraphicCircleControlZone: GraphicBaseZone {

    //可顯示區域
    var SHOW_PERCENT:CGFloat = 7/10
    //編輯bar
    var editView:GraphicBaseEditorView!
    override var MINI_SIZE:CGSize{
        if deviceList.count == 0{
            return CGSize.init(width: 100, height: 100)
        }else{
            let rect = getDeviceRect()
            return CGSize.init(width: rect.width * GraphicEditorUtils.BASE_SIZE.width / SHOW_PERCENT, height: rect.height * GraphicEditorUtils.BASE_SIZE.height / SHOW_PERCENT)
        }
    }
    override var gWidth: CGFloat{
        return self.width
    }
    override var gHeight: CGFloat{
        return self.height + editView.height
    }
    override var MinorType: GraphicEditorUtils.ZoneType{
        return .CircleControl
    }
    override var Name: String{
        get{
            return editView?.GetName() ?? ""
        }
        set{
            editView?.SetName(name: newValue)
        }
    }
    
    override func initialize() {
        super.initialize()
        zone.viewCornerRadius = width / 2
        
        editView = GraphicZoneEditorView.init(frame: CGRect.init(x: 0, y: frame.height, width: frame.width, height: GraphicEditorUtils.ZONE_EDITOR_SIZE.height))
        editView.SetFocus(isSelect: false)
        editView.del = self
        self.addSubview(editView)
    }


    override func SetFocus(isSelect:Bool){
        super.SetFocus(isSelect: isSelect)
        editView?.SetFocus(isSelect: isSelect)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let editorpoint = self.convert(point, to: editView)
        if editView.bounds.contains(editorpoint) {
            return editView.hitTest(editorpoint, with: event)
        }
        let tmp = super.hitTest(point, with: event)
        //print("GraphicBaseZone\(tmp)")
        return tmp
    }
    
    override func Scale(scale: CGFloat) {
        super.Scale(scale: scale)
        
        editView?.Scale(scale: scale)
        let oriSize = editView?.size ?? .zero
        let width = max(GraphicEditorUtils.ZONE_EDITOR_SIZE.width/scale, frame.width)
        editView?.frame = CGRect.init(x: (frame.width - width)/2, y: frame.height, width: max(GraphicEditorUtils.ZONE_EDITOR_SIZE.width/scale, frame.width), height: oriSize.height)
        editView?.Resize()
    }
    
    override func Resize(toSize: CGSize) {
        //print("toSize\(toSize)")
        let size1 = max(toSize.width, toSize.height)
        //print("size1\(size1)")
        //print("MINI_SIZE\(MINI_SIZE)")
        let size2 = max(MINI_SIZE.width, MINI_SIZE.height)
        let circleSize = max(size1, size2)
        let resize = CGSize.init(width: circleSize, height: circleSize)
        //print("resize\(circleSize)")
        self.frame = CGRect.init(x: x - (resize.width - size.width)/2 , y: y - (resize.height - size.height)/2, width: resize.width, height: resize.height)
        gFrame = getGFrame()
        
        zone?.frame = CGRect.init(origin: .zero, size: resize)
        zone?.viewCornerRadius = circleSize / 2
        
        instruction?.frame = CGRect.init(x: frame.width-instructionSize.width, y: 0, width: instructionSize.width, height: instructionSize.height)
        
        editView?.Scale(scale: scale)
        let oriSize = editView?.size ?? .zero
        let width = max(GraphicEditorUtils.ZONE_EDITOR_SIZE.width/scale, frame.width)
        editView?.frame = CGRect.init(x: (frame.width - width)/2, y: frame.height, width: max(GraphicEditorUtils.ZONE_EDITOR_SIZE.width/scale, frame.width), height: oriSize.height)
        editView?.Resize()
        
        reloadPositionInZone()
    }
    
    override func AddDevice(type: GraphicEditorUtils.DeviceType, gframe: GraphicEditorUtils.GraphicFrame) -> GraphicBaseDevice {
        let device = super.AddDevice(type: type, gframe: gframe)
        
        
        //調整大小
        let grect = getDeviceRect()
        //圓周內正方形
        var realSize = CGSize.init(width: grect.width / SHOW_PERCENT, height: grect.height / SHOW_PERCENT)
        if realSize.width < gFrame.width{
            realSize.width = gFrame.width
        }
        if realSize.height < gFrame.height{
            realSize.height = gFrame.height
        }
        Resize(toSize: realSize)
        return device
    }
    
    override func AddDevice(types: [GraphicEditorUtils.DeviceType], gframe: GraphicEditorUtils.GraphicFrame) -> [GraphicBaseDevice] {
        let devices = super.AddDevice(types: types, gframe: gframe)
        
        //調整大小
        let grect = getDeviceRect()
        //圓周內正方形
        var realSize = CGSize.init(width: grect.width / SHOW_PERCENT, height: grect.height / SHOW_PERCENT)
        if realSize.width < gFrame.width{
            realSize.width = gFrame.width
        }
        if realSize.height < gFrame.height{
            realSize.height = gFrame.height
        }
        Resize(toSize: realSize)
        return devices
    }
    
    override func reloadPositionInZone() {
        var deviceRect = getDeviceRect()
        let zoneRect = gFrame
        let showSize = CGSize.init(width: gFrame.width * SHOW_PERCENT, height: gFrame.height * SHOW_PERCENT)
        //顯示範圍大於最小範圍
        if deviceRect.width < showSize.width{
            deviceRect.x -= (showSize.width - deviceRect.width)/2
            deviceRect.width = showSize.width
        }
        //print("reloadPositionInZone\(deviceRect)")
        //print(zoneRect.height)
        //print(deviceRect.height)
        if deviceRect.height < showSize.height{
            deviceRect.y -= (showSize.height - deviceRect.height)/2
            deviceRect.height = showSize.height
        }
        //print("reloadPositionInZone\(deviceRect)")
        for item in deviceList{
            //print(item.gFrame)
            let point = CGPoint.init(x: item.gFrame.x - deviceRect.x + zoneRect.width * ((1 - SHOW_PERCENT) / 2) , y: item.gFrame.y - deviceRect.y + zoneRect.height * ((1 - SHOW_PERCENT) / 2))
            //print(point)
            item.frame = CGRect.init(x: point.x * GraphicEditorUtils.BASE_SIZE.width, y: point.y * GraphicEditorUtils.BASE_SIZE.height, width: item.gFrame.width, height: item.gFrame.height)
        }
    }
}

extension GraphicCircleControlZone:GraphicBaseEditorViewDelegate{
    func OnEditorClick() {
        del.OnEditorClick(item: self)
    }
    
    func OnPowerClick(isOn: Bool) {
        del.OnEditorPowerClick(item: self, isOn: isOn)
    }
}
