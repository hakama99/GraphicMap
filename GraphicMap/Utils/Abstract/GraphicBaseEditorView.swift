//
//  Modal.swift
//  ModalView
//
//  Created by Aatish Rajkarnikar on 3/20/17.
//  Copyright © 2017 Aatish. All rights reserved.
//

import Foundation
import UIKit

@objc protocol GraphicBaseEditorViewDelegate {
    func OnEditorClick()
    func OnPowerClick(isOn:Bool)
}

class GraphicBaseEditorView: UIView {
    var del:GraphicBaseEditorViewDelegate!
    //當前縮放
    var scale:CGFloat =  1
    var isPowerOn = false
    var isSelect = false
    
    var SELECT_BG_COLOR = UIColor.init(red: 240, green: 91, blue: 40, alpha: 1)
    var DEFAULT_BG_COLOR = UIColor.init(red: 66, green: 69, blue: 79, alpha: 0.4)
    var SELECT_FG_COLOR = UIColor.init(red: 66, green: 69, blue: 79, alpha: 0.4)
    var DEFAULT_FG_COLOR = UIColor.init(red: 66, green: 69, blue: 79, alpha: 1)
    
    var SELECT_TEXT_COLOR = UIColor.init(red: 255, green: 255, blue: 255, alpha: 1)
    var DEFAULT_TEXT_COLOR = UIColor.init(red: 255, green: 255, blue: 255, alpha: 1)
    
    var SELECT_POWER_COLOR = UIColor.init(red: 255, green: 255, blue: 255, alpha: 1)
    var DEFAULT_POWER_COLOR = UIColor.init(red: 95, green: 99, blue: 113, alpha: 1)
    var editLabelSize:CGFloat = 15
    //UI
    var fgView:UIView!
    var nameBtn:UIButton!
    var powerBtn:UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func initialize() {
        self.backgroundColor = DEFAULT_BG_COLOR
        
        
        fgView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height))
        fgView.backgroundColor = DEFAULT_FG_COLOR
        self.addSubview(fgView)
        
        nameBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height))
        nameBtn.setTitleColor(DEFAULT_TEXT_COLOR, for: .normal)
        nameBtn.setTitle("", for: .normal)
        nameBtn.titleLabel?.font = UIFont.init(name: GraphicEditorUtils.FONT_NAME, size: editLabelSize)
        nameBtn.addTarget(self, action: #selector(onEditorClick), for: .touchUpInside)
        self.addSubview(nameBtn)
        
        powerBtn = UIButton.init(frame: CGRect.init(x: frame.width - 30, y: 0, width: 20, height: frame.height))
        powerBtn.setImage(UIImage.init(named: "ic_control_power_select_off")?.reSizeImage(reSize: .init(width: 20, height: 20)).withRenderingMode(.alwaysTemplate), for: .normal)
        powerBtn.tintColor = DEFAULT_POWER_COLOR
        powerBtn.addTarget(self, action: #selector(onPowerClick), for: .touchUpInside)
        self.addSubview(powerBtn)
    }
    
    func SetName(name:String){
        nameBtn.setTitle(name, for: .normal)
    }
    
    func GetName()->String{
        return nameBtn.title(for: .normal) ?? ""
    }
    
    func SetFocus(isSelect:Bool){
        self.isSelect = isSelect

        self.backgroundColor = isSelect ? SELECT_BG_COLOR : DEFAULT_BG_COLOR
        fgView?.backgroundColor = isSelect ? SELECT_FG_COLOR : DEFAULT_FG_COLOR
        nameBtn.isUserInteractionEnabled = isSelect
        powerBtn.isUserInteractionEnabled = isSelect
    }
    
    func Scale(scale:CGFloat){
        self.scale = scale
        self.transform = CGAffineTransform(scaleX: 1/scale, y: 1/scale)
    }
    
    func Resize(){
        
    }
    
    func SetPower(isOn:Bool){
        isPowerOn = isOn
        powerBtn?.tintColor = isOn ? SELECT_POWER_COLOR : DEFAULT_POWER_COLOR
    }
    
    @objc func onEditorClick(){
        del?.OnEditorClick()
    }
    
    @objc func onPowerClick(){
        del?.OnPowerClick(isOn: isPowerOn)
    }
}
