//
//  Modal.swift
//  ModalView
//
//  Created by Aatish Rajkarnikar on 3/20/17.
//  Copyright © 2017 Aatish. All rights reserved.
//

import Foundation
import UIKit

class GraphicZoneEditorView: GraphicBaseEditorView {
    

    override func initialize() {
        super.initialize()
        
        fgView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        nameBtn.frame = CGRect.init(x: 0, y: 0, width: frame.width - 30, height: frame.height)
        powerBtn?.frame = CGRect.init(x: frame.width - 30, y: 0, width: 20, height: frame.height)
        
        
        self.customCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: GraphicEditorUtils.DEFAULT_RADIUS)
        fgView.customCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: GraphicEditorUtils.DEFAULT_RADIUS)
        
        nameBtn.setImage(UIImage.init(named: "ic_drop_down_small_white"), for: .normal)
        nameBtn.contentHorizontalAlignment = .left
        nameBtn.semanticContentAttribute = .forceRightToLeft
        nameBtn.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        //nameBtn.imageEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    override func SetFocus(isSelect:Bool){
        super.SetFocus(isSelect: isSelect)
    }
    
    override func Scale(scale: CGFloat) {
        super.Scale(scale: scale)
        
        self.customCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: GraphicEditorUtils.DEFAULT_RADIUS * scale)
        fgView?.customCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: GraphicEditorUtils.DEFAULT_RADIUS * scale)
    }
    
    override func Resize() {
        super.Resize()
        fgView?.frame = CGRect.init(x: 0, y: 0, width: frame.width * scale, height: frame.height * scale)
        nameBtn?.frame = CGRect.init(x: 0, y: 0, width: frame.width * scale - 30, height: frame.height * scale)
        powerBtn?.frame = CGRect.init(x: frame.width * scale - 30, y: 0, width: 20, height: frame.height * scale)
    }
}
