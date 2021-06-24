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
            self.view.addSubview(map)
        }
    }
    
    @IBAction func createdesample(_ sender: Any) {
        if let map = map{
            let zone = map.AddZone(type: .SquareControl, gframe: GraphicEditorUtils.GraphicFrame.init(x: -40, y: 0, width: 10, height: 10))
            zone.Name = "test1"
            
            let zone1 = map.AddZone(type: .CircleControl, gframe: GraphicEditorUtils.GraphicFrame.init(x: -30, y: 0, width: 10, height: 10))
            zone1.Name="test2"
            
            let zone2 = map.AddZone(type: .Square, gframe: GraphicEditorUtils.GraphicFrame.init(x: -20, y: 0, width: 10, height: 10))

            let zone3 = map.AddZone(type: .Circle, gframe: GraphicEditorUtils.GraphicFrame.init(x: -10, y: 0, width: 10, height: 10))
            
            let zone4 = map.AddZone(type: .Label, gframe: GraphicEditorUtils.GraphicFrame.init(x: 0, y: 0, width: 10, height: 5))
            zone4.Name = "test4"
            
            let d = map.AddDevice(types: [.Light,.Beacon,.Sensor,.Gateway], gframe: .init(x: 10, y: 20, width: 40, height: 40))
            for i in 0..<d.count{
                d[i].Name="test\(i)"
            }
        }
    }
    
    @IBAction func createDeviceinZone(_ sender: Any) {
        if let map = map{
            let zone = map.AddZone(type: .SquareControl, gframe: GraphicEditorUtils.GraphicFrame.init(x: 0, y: 10, width: 10, height: 10))
            zone.Name = "test1"
            let d = zone.AddDevice(types: [.Light,.Beacon,.Sensor,.Gateway], gframe: .init(x: -5, y: 0, width: 20, height: 20))
            for i in 0..<d.count{
                d[i].Name = "test\(i)"
            }
            
            
            let zone2 = map.AddZone(type: .CircleControl, gframe: GraphicEditorUtils.GraphicFrame.init(x: 10, y: 10, width: 10, height: 10))
            zone2.Name="test2"
            let d2 = zone2.AddDevice(types: [.Light,.Beacon,.Sensor,.Gateway], gframe: .init(x: -5, y: 0, width: 20, height: 20))
            for i in 0..<d2.count{
                d[i].Name = "test\(i)"
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
        let zones = map.DeviceList
        tempData = JSON.init([])
        for zone in zones{
            var zData = zone.gFrame.json
            if let z = zone as? GraphicBaseZone{
                zData["major_type"].intValue = z.MajorType.rawValue
                zData["minor_type"].intValue = z.MinorType.rawValue
                zData["name"].stringValue = z.Name
                zData["devices"].arrayObject = []
                for device in z.DeviceList{
                    var dData = device.gFrame.json
                    dData["major_type"].intValue = device.MajorType.rawValue
                    dData["minor_type"].intValue = device.MinorType.rawValue
                    dData["name"].stringValue = device.Name
                    zData["devices"].arrayObject?.append(dData)
                }
                
            }else if let d = zone as? GraphicBaseDevice{
                zData["major_type"].intValue = d.MajorType.rawValue
                zData["minor_type"].intValue = d.MinorType.rawValue
                zData["name"].stringValue = d.Name
            }
            tempData.arrayObject?.append(zData)
        }
        print(tempData)
        map?.Clean()
    }
    
    @IBAction func showData(_ sender: Any) {
        map?.Clean()
        if let arr = tempData?.array{
            for zoneData in arr{
                if zoneData["major_type"].exists(),zoneData["minor_type"].exists(){
                    let major_type = zoneData["major_type"].intValue
                    let minor_type = zoneData["minor_type"].intValue
                    switch GraphicEditorUtils.MajorType.init(rawValue: major_type) {
                    case .Zone:
                        let zone = map?.AddZone(type: .init(rawValue: minor_type) ?? .Unknow, gframe: .init(json: zoneData))
                        zone?.Name = zoneData["name"].exists() ? zoneData["name"].stringValue : ""
                        if zoneData["devices"].exists(),let deviceArr = zoneData["devices"].array{
                            for deviceData in deviceArr{
                                if deviceData["major_type"].exists(),deviceData["minor_type"].exists(){
                                    let minor_type = deviceData["minor_type"].intValue
                                    let device = zone?.AddDevice(type: .init(rawValue: minor_type) ?? .Unknow, gframe: .init(json: deviceData))
                                    device?.Name = deviceData["name"].exists() ? deviceData["name"].stringValue : ""
                                }
                            }
                        }
                    case .Device:
                        let device = map?.AddDevice(type: .init(rawValue: minor_type) ?? .Unknow, gframe: .init(json: zoneData))
                        device?.Name = zoneData["name"].exists() ? zoneData["name"].stringValue : ""
                    default:
                        break
                    }
                }
            }
        }
    }
}

