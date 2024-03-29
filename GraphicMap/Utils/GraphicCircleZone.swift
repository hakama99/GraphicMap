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

class GraphicCircleZone: GraphicBaseZone {

    override var SELECT_COLOR: UIColor{
        get {
            return UIColor.init(red: 240, green: 91, blue: 40, alpha: 0.7)
        }
        set {
        }
    }
    override var DEFAULT_COLOR: UIColor{
        get {
            return UIColor.init(red: 66, green: 69, blue: 79, alpha: 0.7)
        }
        set {
        }
    }
    var SELECT_BORDER_COLOR = UIColor.init(red: 240, green: 91, blue: 40, alpha: 1)
    var DEFAULT_BORDER_COLOR = UIColor.init(red: 141, green: 148, blue: 169, alpha: 1)
    override var MinorType: GraphicEditorUtils.ZoneType{
        return .Circle
    }
    
    override func initialize() {
        super.initialize()
        zoneView.viewBorderWidth = 2
        zoneView.viewBorderColor = DEFAULT_BORDER_COLOR
        zoneView.viewCornerRadius = width / 2
    }


    override func SetFocus(isSelect:Bool){
        super.SetFocus(isSelect: isSelect)
        
        zoneView.viewBorderColor = isSelect ? SELECT_BORDER_COLOR : DEFAULT_BORDER_COLOR
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let tmp = super.hitTest(point, with: event)
        //print("GraphicBaseZone\(tmp)")
        return tmp
    }
    
    override func Scale(scale: CGFloat) {
        super.Scale(scale: scale)
    }
    
    override func Resize(toSize: CGSize) {
        super.Resize(toSize: toSize)
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
        
        zoneView?.frame = CGRect.init(origin: .zero, size: resize)
        zoneView?.viewCornerRadius = circleSize / 2
    }
}

