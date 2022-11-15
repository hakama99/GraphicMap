//
//  ViewController.swift
//  GraphicMap
//
//  Created by 陳力維 on 2021/6/24.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var map:GraphicMap!
    @IBAction func createmap(_ sender: Any) {
        if map == nil{
            map = GraphicMap.init(frame: CGRect.init(x: 0, y: 300, width: self.view.bounds.width, height: self.view.bounds.height-300),mapSize: CGSize.init(width: 200, height: 200))
            map.del = self
            self.view.addSubview(map)
            map.SetZoomScale(scale: GraphicEditorUtils.ZOOM_MIN_SCALE)
        }
    }
    
    @IBAction func createdesample(_ sender: Any) {
        map?.Clean()
        if let map = map{
            let zone = map.AddZone(type: .SquareControl, gframe: GraphicEditorUtils.GraphicFrame.init(x: -40, y: 0, width: 10, height: 10))
            zone.Name = "zone0"
            
            let zone1 = map.AddZone(type: .CircleControl, gframe: GraphicEditorUtils.GraphicFrame.init(x: -30, y: 0, width: 10, height: 10))
            zone1.Name="zone1"
            
            let zone2 = map.AddZone(type: .Square, gframe: GraphicEditorUtils.GraphicFrame.init(x: -20, y: 0, width: 10, height: 10))

            let zone3 = map.AddZone(type: .Circle, gframe: GraphicEditorUtils.GraphicFrame.init(x: -10, y: 0, width: 10, height: 10))
            
            let zone4 = map.AddZone(type: .Label, gframe: GraphicEditorUtils.GraphicFrame.init(x: 0, y: 0, width: 10, height: 5))
            zone4.Name = "zone4"
            
            let d = map.AddDevice(types: [.Light,.Beacon,.Sensor,.Gateway], gframe: .init(x: 10, y: 20, width: 40, height: 40))
            for i in 0..<d.count{
                d[i].Name="device\(i)"
            }
        }
    }
    
    @IBAction func createDeviceinZone(_ sender: Any) {
        map?.Clean()
        if let map = map{
            let zone = map.AddZone(type: .SquareControl, gframe: GraphicEditorUtils.GraphicFrame.init(x: 0, y: 10, width: 10, height: 10))
            zone.Name = "zone1"
            let d = zone.AddDevice(types: [.Light,.Beacon,.Sensor,.Gateway], gframe: .init(x: -5, y: 0, width: 20, height: 20))
            for i in 0..<d.count{
                d[i].Name = "test\(i)"
            }
            
            
            let zone2 = map.AddZone(type: .CircleControl, gframe: GraphicEditorUtils.GraphicFrame.init(x: 10, y: 10, width: 10, height: 10))
            zone2.Name="zone2"
            for i in 0..<4{
                let d2 = zone2.AddDevice(type: GraphicEditorUtils.GraphicDeviceType.init(rawValue: i + 1) ?? .Light, gframe: .init(x: CGFloat(-5 + i * 5), y: 0, width: 20, height: 20))
                d2.Name = "device\(i)"
            }
        }
    }
    
    
    @IBAction func zoomin(_ sender: Any) {
        map?.SetZoomScale(scale: map.GetZoomScale()+0.1)
    }
    @IBAction func zoomout(_ sender: Any) {
        //print("aa")
        map?.SetZoomScale(scale: map.GetZoomScale()-0.1)
    }
    @IBAction func clean(_ sender: Any) {
        //print("bb")
        map?.Clean()
    }
    
    var tempData:JSON!
    @IBAction func saveData(_ sender: Any) {
        //print("bb")
        tempData = map?.exportData()
        print("saveData:\(tempData)")
        map?.Clean()
    }
    
    @IBAction func showData(_ sender: Any) {
        map?.Clean()
        map?.importData(json: tempData)
    }
}


extension ViewController:GraphicMapDelegate{
    @objc func OnItemClick(item:GraphicBaseAbstract){
        print("click item: \(item)")
    }
    
    @objc func OnItemDragEnd(item:GraphicBaseAbstract,recognizer:UIPanGestureRecognizer){
        print("OnItemDragEnd item frame:\(item.gFrame)")
    }
    
    @objc func OnItemScaleEnd(item:GraphicBaseAbstract,recognizer:UIPanGestureRecognizer){
        print("OnItemScaleEnd item frame:\(item.gFrame)")
    }
    
    @objc func OnEditorClick(item:GraphicBaseAbstract){
        print("OnEditorClick item frame:\(item)")
        
        if let zone = item as? GraphicBaseZone{
            var tempData = zone.exportData()
            print("enter child zone :\(tempData)")
            map?.Clean()
            map?.importData(json: tempData)
        }else if let device = item as? GraphicBaseDevice{
            
        }
    }
    
    @objc func OnEditorPowerClick(item:GraphicBaseAbstract,isOn:Bool){
        print("OnEditorPowerClick item :\(item)")
    }
}
