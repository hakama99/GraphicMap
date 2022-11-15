//
//  Modal.swift
//  ModalView
//
//  Created by Aatish Rajkarnikar on 3/20/17.
//  Copyright © 2017 Aatish. All rights reserved.
//

import Foundation
import UIKit

class GraphicDeviceEditorView: GraphicBaseEditorView {
    var SELECT_STATUS_COLOR = UIColor.init(red: 240, green: 91, blue: 40, alpha: 0.7)
    var DEFAULT_STATUS_COLOR = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
    
    //UI
    var statusLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(origin: frame.origin, size: frame.size))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initialize() {
        super.initialize()
        self.viewCornerRadius = GraphicEditorUtils.DEFAULT_RADIUS
        fgView.viewCornerRadius = GraphicEditorUtils.DEFAULT_RADIUS
        fgView?.frame = CGRect.init(x: 0, y: 0, width: frame.width * scale, height: frame.height * scale)
        nameBtn.contentHorizontalAlignment = .center
        nameBtn.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        nameBtn.frame = CGRect.init(origin: .zero, size: CGSize.init(width: width, height: height / 2))
        nameBtn.isUserInteractionEnabled = false
        
        powerBtn.frame = CGRect.init(x: 0, y: height/2, width: width, height: height/2)
        
        statusLabel = UILabel.init(frame: bounds)
        statusLabel.backgroundColor = DEFAULT_STATUS_COLOR
        statusLabel.viewCornerRadius = GraphicEditorUtils.DEFAULT_RADIUS
        statusLabel.viewBorderWidth = 1
        statusLabel.viewBorderColor = .white
        statusLabel.font = UIFont.init(name: GraphicEditorUtils.FONT_NAME, size: 15)
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.isHidden = true
        statusLabel.text = "未配對"
        self.addSubview(statusLabel)
    }
    
    override func SetFocus(isSelect:Bool){
        super.SetFocus(isSelect: isSelect)
        
        statusLabel.backgroundColor = isSelect ? SELECT_STATUS_COLOR : DEFAULT_STATUS_COLOR
    }
    
    override func Scale(scale: CGFloat) {
        super.Scale(scale: scale)
        
        self.viewCornerRadius = GraphicEditorUtils.DEFAULT_RADIUS * scale
        fgView?.viewCornerRadius = GraphicEditorUtils.DEFAULT_RADIUS * scale
    }
    
    override func Resize() {
        super.Resize()
        
        fgView?.frame = CGRect.init(x: 0, y: 0, width: frame.width * scale, height: frame.height * scale)
        nameBtn?.frame = CGRect.init(x: 0, y: 0, width: width * scale, height: height/2 * scale)
        powerBtn?.frame = CGRect.init(x: 0, y: height/2 * scale, width: width * scale, height: height/2 * scale)
        statusLabel?.frame = CGRect.init(x: 0, y: 0, width: width * scale, height: height * scale)
    }
    
    override func SetPower(isOn: Bool) {
        super.SetPower(isOn: isOn)
    }
    
    func SetStatus(isOut:Bool){
        statusLabel?.isHidden = !isOut
    }
}
