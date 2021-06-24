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

class GraphicSquareZone: GraphicBaseZone {

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
        return .Square
    }
    
    override func initialize() {
        super.initialize()
        zone.viewBorderWidth = 2
        zone.viewBorderColor = DEFAULT_BORDER_COLOR
        zone.viewCornerRadius = GraphicEditorUtils.DEFAULT_RADIUS
        
        instruction.frame = CGRect.init(x: frame.width, y: -instructionSize.height, width: instructionSize.width, height: instructionSize.height)
    }


    override func SetFocus(isSelect:Bool){
        super.SetFocus(isSelect: isSelect)
        
        zone.viewBorderColor = isSelect ? SELECT_BORDER_COLOR : DEFAULT_BORDER_COLOR
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let instructionpoint = self.convert(point, to: instruction)
        if instruction.bounds.contains(instructionpoint) {
            return instruction.hitTest(instructionpoint, with: event)
        }
        let tmp = super.hitTest(point, with: event)
        //print("GraphicBaseZone\(tmp)")
        return tmp
    }
    
    override func Scale(scale: CGFloat) {
        super.Scale(scale: scale)
    }
    
    override func Resize(toSize: CGSize) {
        super.Resize(toSize: toSize)
        
        instruction.frame = CGRect.init(x: frame.width, y: -instructionSize.height, width: instructionSize.width, height: instructionSize.height)
    }
}

