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

class GraphicSquareControlZone: GraphicBaseZone {

    //編輯bar
    var editView:GraphicBaseEditorView!
    override var gWidth: CGFloat{
        return self.width
    }
    override var gHeight: CGFloat{
        return self.height + editView.height
    }
    override var MinorType: GraphicEditorUtils.ZoneType{
        return .SquareControl
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
        zone.customCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: GraphicEditorUtils.DEFAULT_RADIUS)
        
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
        super.Resize(toSize: toSize)

        editView?.Scale(scale: scale)
        let oriSize = editView?.size ?? .zero
        let width = max(GraphicEditorUtils.ZONE_EDITOR_SIZE.width/scale, frame.width)
        editView?.frame = CGRect.init(x: (frame.width - width)/2, y: frame.height, width: max(GraphicEditorUtils.ZONE_EDITOR_SIZE.width/scale, frame.width), height: oriSize.height)
        editView?.Resize()
    }
    
    override func AddDevice(type: GraphicEditorUtils.DeviceType, gframe: GraphicEditorUtils.GraphicFrame) -> GraphicBaseDevice {
        let device = super.AddDevice(type: type, gframe: gframe)
        
        
        //調整大小
        var grect = getDeviceRect()
        if grect.width < gFrame.width{
            grect.width = gFrame.width
        }
        if grect.height < gFrame.height{
            grect.height = gFrame.height
        }
        Resize(toSize: grect.frame.size)
        return device
    }
    
    override func AddDevice(types: [GraphicEditorUtils.DeviceType], gframe: GraphicEditorUtils.GraphicFrame) -> [GraphicBaseDevice] {
        let devices = super.AddDevice(types: types, gframe: gframe)
        
        //調整大小
        var grect = getDeviceRect()
        if grect.width < gFrame.width{
            grect.width = gFrame.width
        }
        if grect.height < gFrame.height{
            grect.height = gFrame.height
        }
        Resize(toSize: grect.frame.size)
        return devices
    }
    
    override func reloadPositionInZone() {
        var deviceRect = getDeviceRect()
        let zoneRect = gFrame
        //顯示範圍大於最小範圍
        if deviceRect.width < zoneRect.width{
            deviceRect.x -= (zoneRect.width - deviceRect.width)/2
            deviceRect.width = zoneRect.width
        }
        //print("reloadPositionInZone\(deviceRect)")
        //print(zoneRect.height)
        //print(deviceRect.height)
        if deviceRect.height < zoneRect.height{
            deviceRect.y -= (zoneRect.height - deviceRect.height)/2
            deviceRect.height = zoneRect.height
        }
        //print("reloadPositionInZone\(deviceRect)")
        for item in deviceList{
            //print(item.gFrame)
            let point = CGPoint.init(x: item.gFrame.x - deviceRect.x, y: item.gFrame.y - deviceRect.y)
            //print(point)
            item.frame = CGRect.init(x: point.x * GraphicEditorUtils.BASE_SIZE.width, y: point.y * GraphicEditorUtils.BASE_SIZE.height, width: item.gFrame.width, height: item.gFrame.height)
        }
    }
}

extension GraphicSquareControlZone:GraphicBaseEditorViewDelegate{
    func OnEditorClick() {
        del.OnEditorClick(item: self)
    }
    
    func OnPowerClick(isOn: Bool) {
        del.OnEditorPowerClick(item: self, isOn: isOn)
    }
}
