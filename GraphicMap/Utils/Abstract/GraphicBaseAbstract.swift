//
//  Modal.swift
//  ModalView
//
//  Created by Aatish Rajkarnikar on 3/20/17.
//  Copyright © 2017 Aatish. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

@objc protocol GraphicBaseAbstractDelegate {
    @objc func OnItemClick(item:GraphicBaseAbstract)
    @objc func OnItemDrag(item:GraphicBaseAbstract,recognizer:UIPanGestureRecognizer)
    @objc func OnItemScale(item:GraphicBaseAbstract,recognizer:UIPanGestureRecognizer)
    @objc func OnEditorClick(item:GraphicBaseAbstract)
    @objc func OnEditorPowerClick(item:GraphicBaseAbstract,isOn:Bool)
}

class GraphicBaseAbstract:UIView {
    
    //物件ID
    @objc public var data:Any!
    //位置資訊
    @objc public var gFrame:GraphicEditorUtils.GraphicFrame = GraphicEditorUtils.GraphicFrame.init()
    //委託事件
    @objc public var del:GraphicBaseAbstractDelegate!
    //判斷點擊事件
    var isClick = false
    //是否連線
    @objc public var isOn:Bool = true
    //是否focus
    @objc public var isSelect = false
    //可否控制
    @objc public var canControl = false
    //當前縮放
    @objc public var scale:CGFloat =  1
    //包含額外物件(編輯bar)之寬
    @objc public var gWidth:CGFloat{
        return self.width
    }
    //包含額外物件(編輯bar)之高
    @objc public var gHeight:CGFloat{
        return self.height
    }
    @objc public var Name:String{
        get{
            return ""
        }
        set{
        }
    }
    //類型
    public var MajorType:GraphicEditorUtils.MajorType{
        return .Unknow
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialize() {
        
    }
    
    @objc public func SetFocus(isSelect:Bool){
        self.isSelect = isSelect
    }
    
    @objc public func Scale(scale:CGFloat){
        self.scale = scale
    }
    
    @objc public func Resize(toSize:CGSize){
        
    }
    
    @objc public func SetPower(isOn: Bool) {
        self.isOn = isOn
    }
    
    @objc public func SetControl(canControl: Bool) {
        self.canControl = canControl
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //print("touchesBegan\(self) \(touches) \(event)")
        isClick = true
        //del?.OnItemClick?(item: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        //print("touchesMoved\(self)")
        isClick = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        //print("touchesEnded\(self)")
        if isClick{
            isClick = false
            del?.OnItemClick(item: self)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let tmp = super.hitTest(point, with: event)
        //print("\(self) hitTest \(tmp)")
        return tmp
    }
    
    //取得當前位置
    final func getGFrame()->GraphicEditorUtils.GraphicFrame{
        if let map = self.superview{
            let x = self.frame.minX - map.width/2 / map.transform.a
            let y = self.frame.minY - map.height/2 / map.transform.d
            return GraphicEditorUtils.GraphicFrame.init(x: x == 0 ? 0 : x / GraphicEditorUtils.BASE_SIZE.width , y: y == 0 ? 0 : y / GraphicEditorUtils.BASE_SIZE.height, width: width / GraphicEditorUtils.BASE_SIZE.width, height: height / GraphicEditorUtils.BASE_SIZE.height)
        }else{
            print("error: can't find superview")
            return .init()
        }
    }
}
