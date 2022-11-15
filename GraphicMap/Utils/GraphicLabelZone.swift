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
            return GraphicEditorUtils.MINI_SIZE
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
            return label?.text ?? ""
        }
        set{
            label?.text = newValue
        }
    }
    
    var label:UILabel!
    var labelOffset:CGFloat = 10
    
    override func initialize() {
        super.initialize()
        zoneView.viewBorderWidth = 2
        zoneView.viewBorderColor = DEFAULT_BORDER_COLOR
        zoneView.viewCornerRadius = GraphicEditorUtils.DEFAULT_RADIUS
        
        label = UILabel.init(frame: CGRect.init(x: labelOffset, y: 0, width: width-labelOffset*2, height: height))
        label.text = ""
        label.font = UIFont.init(name: GraphicEditorUtils.FONT_NAME, size: 15)
        label.textColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 1)
        label.textAlignment = .left
        label.numberOfLines = 0
        self.addSubview(label)
    }


    override func SetFocus(isSelect:Bool){
        super.SetFocus(isSelect: isSelect)
        
        zoneView.viewBorderColor = isSelect ? SELECT_BORDER_COLOR : DEFAULT_BORDER_COLOR
        
        //textfield.isUserInteractionEnabled = isSelect
    }
    
    
    override func Scale(scale: CGFloat) {
        super.Scale(scale: scale)
    }
    
    override func Resize(toSize: CGSize) {
        super.Resize(toSize: toSize)
        
        let resize = CGSize.init(width: max(toSize.width, MINI_SIZE.width), height: max(toSize.height, MINI_SIZE.height))
        label.frame = CGRect.init(x: 5, y: 0, width: resize.width-10, height: resize.height)
    }
    
    @objc func dismissKeyBoard() {
        endEditing(true)
    }
}

