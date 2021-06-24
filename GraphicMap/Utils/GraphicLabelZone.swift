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

class GraphicLabelZone: GraphicBaseZone {

    override var MINI_SIZE: CGSize{
        get {
            return CGSize.init(width: 100, height: 50)
        }
        set {
        }
    }
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
        return .Label
    }
    override var Name: String{
        get{
            return textfield?.text! ?? ""
        }
        set{
            textfield?.text = newValue
        }
    }
    
    var textfield:UITextField!
    
    override func initialize() {
        super.initialize()
        zone.viewBorderWidth = 2
        zone.viewBorderColor = DEFAULT_BORDER_COLOR
        zone.viewCornerRadius = GraphicEditorUtils.DEFAULT_RADIUS
        
        instruction.frame = CGRect.init(x: frame.width, y: -instructionSize.height, width: instructionSize.width, height: instructionSize.height)
        
        textfield = UITextField.init(frame: CGRect.init(origin: .zero, size: size))
        textfield.font = UIFont.init(name: GraphicEditorUtils.FONT_NAME, size: 15)
        textfield.textColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 1)
        textfield.paddingLeftCustom = 10
        textfield.paddingRightCustom = 10
        textfield.textAlignment = .left
        textfield.isUserInteractionEnabled = false
        
        textfield.addTarget(self, action: #selector(dismissKeyBoard), for: .editingDidEndOnExit)
        self.addSubview(textfield)
    }


    override func SetFocus(isSelect:Bool){
        super.SetFocus(isSelect: isSelect)
        
        zone.viewBorderColor = isSelect ? SELECT_BORDER_COLOR : DEFAULT_BORDER_COLOR
        
        //textfield.isUserInteractionEnabled = isSelect
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
        
        let resize = CGSize.init(width: max(toSize.width, MINI_SIZE.width), height: max(toSize.height, MINI_SIZE.height))
        textfield.frame = CGRect.init(origin: .zero, size: resize)
        
        instruction.frame = CGRect.init(x: frame.width, y: -instructionSize.height, width: instructionSize.width, height: instructionSize.height)
    }
    
    @objc func dismissKeyBoard() {
        endEditing(true)
    }
}

