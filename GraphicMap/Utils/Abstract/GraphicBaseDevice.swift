//
//  Modal.swift
//  ModalView
//
//  Created by Aatish Rajkarnikar on 3/20/17.
//  Copyright © 2017 Aatish. All rights reserved.
//

import Foundation
import UIKit

class GraphicBaseDevice: GraphicBaseAbstract {
    
    //裝置基本大小
    public var DEFAULT_SIZE:CGSize = CGSize.init(width: 5, height: 2)
    
    private var SELECT_COLOR = UIColor.init(red: 240, green: 91, blue: 40, alpha: 1)
    private var DEFAULT_COLOR = UIColor.init(red: 66, green: 69, blue: 79, alpha: 0.4)

    @objc public var isOut:Bool = false
    @objc public var isInZone:Bool = false
    
    //包含額外物件(編輯bar)之寬高
    override var gWidth: CGFloat{
        return max(self.width, editView.width)
    }
    override var gHeight: CGFloat{
        return self.height + editView.height
    }
    //類型
    override var MajorType:GraphicEditorUtils.MajorType{
        return .Device
    }
    var MinorType:GraphicEditorUtils.GraphicDeviceType{
        return .Unknow
    }
    
    override var Name: String{
        get{
            return editView?.GetName() ?? ""
        }
        set{
            editView?.SetName(name: newValue)
        }
    }
    
    //UI
    var deviceImage:UIImageView!
    var editView:GraphicDeviceEditorView!
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(origin: frame.origin, size:  DEFAULT_SIZE.multiply(size: GraphicEditorUtils.BASE_SIZE)))
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func initialize() {
        self.backgroundColor = .clear
        
        deviceImage = UIImageView.init(frame: CGRect.init(origin: .zero, size: size))
        deviceImage.contentMode = .scaleAspectFit
        self.addSubview(deviceImage)
        
        editView = GraphicDeviceEditorView.init(frame: CGRect.init(x: (frame.width - GraphicEditorUtils.DEVICE_EDITOR_SIZE.width) / 2, y: frame.height, width: GraphicEditorUtils.DEVICE_EDITOR_SIZE.width, height: GraphicEditorUtils.DEVICE_EDITOR_SIZE.height))
        editView.SetFocus(isSelect: false)
        editView.del = self
        self.addSubview(editView)
        
        let tap = UIPanGestureRecognizer.init(target: self, action: #selector(gestureMove(recognizer:)))
        self.addGestureRecognizer(tap)
        
        SetFocus(isSelect: false)
    }
    
    override func SetFocus(isSelect: Bool) {
        super.SetFocus(isSelect: isSelect)
        editView?.SetFocus(isSelect: isSelect)
        
        SetImage()
    }
    
    override func Scale(scale: CGFloat) {
        super.Scale(scale: scale)
        
        editView?.Scale(scale: scale)
        let oriSize = editView?.size ?? .zero
        editView?.frame = CGRect.init(x: (frame.width - oriSize.width) / 2, y: frame.height, width: oriSize.width, height: oriSize.height)
        editView?.Resize()
    }
    
    override func Resize(toSize:CGSize){
        super.Resize(toSize: toSize)
        gFrame = getGFrame()
        
        editView?.Scale(scale: scale)
        let oriSize = editView?.size ?? .zero
        editView?.frame = CGRect.init(x: (frame.width - oriSize.width) / 2, y: frame.height, width: oriSize.width, height: oriSize.height)
        editView?.Resize()
    }
    
    override func SetPower(isOn: Bool) {
        super.SetPower(isOn: isOn)
        editView?.SetPower(isOn: self.isOn)
        SetImage()
    }
    
    override func SetControl(canControl: Bool) {
        super.SetControl(canControl: canControl)
        editView?.powerBtn?.isHidden = !canControl
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let tmp = super.hitTest(point, with: event)
        let editorpoint = self.convert(point, to: editView)
        if let view = editView,view.bounds.contains(editorpoint) {
            return editView.hitTest(editorpoint, with: event)
        }
        //print("GraphicBaseZone\(tmp)")
        return tmp
    }
    
    @objc public func SetOffline(isOut:Bool){
        self.isOut = isOut
        

        editView?.SetStatus(isOut: self.isOut)
        SetImage()
    }
    
    func SetImage(isSelect:Bool? = nil,isOn:Bool? = nil,isOut:Bool? = nil){
        if let bo = isSelect{
            self.isSelect = bo
        }
        if let bo = isOn{
            self.isOn = bo
        }
        if let bo = isOut{
            self.isOut = bo
        }
        
        deviceImage.image = GraphicEditorUtils.GetDeviceImage(type: MinorType,isSelect: self.isSelect,isOn: self.isOn,isOut: self.isOut)
        
        editView?.SetStatus(isOut: self.isOut)
        editView?.SetPower(isOn: self.isOn)
    }
    
    @objc public func SetEditorEnable(bo:Bool){
        editView?.isHidden = !bo
    }

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
}

extension GraphicBaseDevice:GraphicBaseEditorViewDelegate{
    func OnEditorClick() {
        del.OnEditorClick(item: self)
    }
    
    func OnPowerClick(isOn: Bool) {
        del.OnEditorPowerClick(item: self, isOn: isOn)
    }
}
