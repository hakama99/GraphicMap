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

@objc protocol GraphicMapDelegate {
    @objc func OnItemClick(item:GraphicBaseAbstract)
    @objc func OnItemDrag(item:GraphicBaseAbstract,recognizer:UIPanGestureRecognizer)
    @objc func OnEditorClick(item:GraphicBaseAbstract)
    @objc func OnEditorPowerClick(item:GraphicBaseAbstract,isOn:Bool)
}

open class GraphicMap: UIControl {
    
    var del:GraphicMapDelegate!
    //地圖大小(基本單位)
    var mapSize:CGSize = CGSize.init(width: 400, height: 400)
    //控制zoom
    var isZoom = false
    //當前比例
    var zoomScale:CGFloat = 1.0
    //物件移動計算
    var movePoint:CGPoint = .zero
    var moveItem:GraphicBaseAbstract!
    
    //UI
    var timer:Timer!
    var scrollview:UIScrollView!
    //地圖基底
    var map:GraphicBaseMap!
    //地圖背景
    var mapBackground:UIImageView!
    //物件清單
    var deviceList:[GraphicBaseAbstract] = []
    var DeviceList:[GraphicBaseAbstract]{
        return deviceList
    }
    //focus物件
    var focusList:[GraphicBaseAbstract] = []
    var FocusList:[GraphicBaseAbstract]{
        return focusList
    }
    
    convenience init(frame: CGRect,mapSize:CGSize) {
        self.init(frame: frame)
        self.mapSize = mapSize
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        deviceList = []
        
        self.backgroundColor = .clear
        
        zoomScale = GraphicEditorUtils.ZOOM_MAX_SCALE
        let mapSize = CGSize.init(width: mapSize.width * GraphicEditorUtils.BASE_SIZE.width * zoomScale, height: mapSize.height * GraphicEditorUtils.BASE_SIZE.height * zoomScale)
        
        scrollview = UIScrollView.init(frame: bounds)
        scrollview.contentSize = mapSize
        // 是否顯示水平的滑動條
        scrollview.showsHorizontalScrollIndicator = false

        // 是否顯示垂直的滑動條
        scrollview.showsVerticalScrollIndicator = false
        // 是否可以滑動
        scrollview.isScrollEnabled = true
        // 是否限制滑動時只能單個方向 垂直或水平滑動
        scrollview.isDirectionalLockEnabled = false

        // 滑動超過範圍時是否使用彈回效果
        scrollview.bounces = false

        
        // 縮放元件的預設縮放大小
        scrollview.zoomScale = zoomScale
        // 縮放元件可縮小到的最小倍數sLE
        scrollview.minimumZoomScale = GraphicEditorUtils.ZOOM_MIN_SCALE
        // 縮放元件可放大到的最大倍數
        scrollview.maximumZoomScale = GraphicEditorUtils.ZOOM_MAX_SCALE
        // 縮放元件縮放時是否在超過縮放倍數後使用彈回效果
        scrollview.bouncesZoom = false
        // 設置委任對象
        scrollview.delegate = self
        // 起始的可見視圖偏移量 預設為 (0, 0)
        // 設定這個值後 就會將原點滑動至這個點起始
        if mapSize.width > frame.width && mapSize.height > frame.height{
            scrollview.contentOffset = CGPoint(
                x: mapSize.width/2 - frame.width / 2, y: mapSize.height/2 - frame.height / 2)
        }else{
            scrollview.contentOffset = .zero
        }
        // 以一頁為單位滑動
        scrollview.isPagingEnabled = false
        self.addSubview(scrollview)
        
        map = GraphicBaseMap.init(frame: CGRect.init(origin: CGPoint.zero, size: mapSize))
        map.del = self
        map.backgroundColor = .clear
        scrollview.addSubview(map)
        
        mapBackground = UIImageView.init()
        mapBackground.frame = CGRect.init(origin: CGPoint.zero, size: mapSize)
        mapBackground.contentMode = .topLeft
        if let image = GraphicEditorUtils.BackgroundImage(size: GraphicEditorUtils.BASE_SIZE)?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left:0, bottom: 0, right: 0), resizingMode: .tile){
            mapBackground.backgroundColor = UIColor.init(patternImage: image)
        }
        
        mapBackground.alpha = 1
        //mapBackground.image = image
        map.addSubview(mapBackground)
    }
    
    func Clean(){
        for item in deviceList{
            if let base = item as? GraphicBaseZone{
                base.Clean()
                base.deviceList = []
            }
            item.removeFromSuperview()
        }
        deviceList = []
    }
    
    func Destroy(){
        timer?.invalidate()
        timer = nil
        
        self.removeFromSuperview()
    }
    
    func AddZone(type:GraphicEditorUtils.ZoneType,gframe:GraphicEditorUtils.GraphicFrame)->GraphicBaseZone{
        
        var zone:GraphicBaseZone!
        switch type {
        case .SquareControl:
            zone = GraphicSquareControlZone.init(frame: gframe.frame)
        case .CircleControl:
            zone = GraphicCircleControlZone.init(frame: gframe.frame)
        case .Square:
            zone = GraphicSquareZone.init(frame: gframe.frame)
        case .Circle:
            zone = GraphicCircleZone.init(frame: gframe.frame)
        case .Label:
            zone = GraphicLabelZone.init(frame: gframe.frame)
        default:
            zone = GraphicBaseZone.init(frame: gframe.frame)
        }
        zone.gFrame = gframe
        zone.del = self
        //先設定原點為中心點再移動至grame座標
        zone.frame.origin = CGPoint.init(x: map.center.x / zoomScale + gframe.frame.minX, y: map.center.y / zoomScale + gframe.frame.minY)
        zone.Scale(scale: zoomScale)
        map.addSubview(zone)
        deviceList.append(zone)
        return zone
    }
    
    func AddDevice(type:GraphicEditorUtils.DeviceType,gframe:GraphicEditorUtils.GraphicFrame)->GraphicBaseDevice{
        
        var device:GraphicBaseDevice!
        switch type {
        case .Light:
            device = GraphicLight.init(frame: gframe.frame)
        case .Beacon:
            device = GraphicBeacon.init(frame: gframe.frame)
            break
        case .Sensor:
            device = GraphicSensor.init(frame: gframe.frame)
            break
        case .Gateway:
            device = GraphicGateway.init(frame: gframe.frame)
            break
        default:
            device = GraphicBaseDevice.init(frame: gframe.frame)
            break
        }
        device.gFrame = gframe
        device.gFrame.width = device.DEFAULT_SIZE.width
        device.gFrame.height = device.DEFAULT_SIZE.height
        device.del = self
        //先設定原點為中心點再移動至grame座標
        device.frame.origin = CGPoint.init(x: map.center.x / zoomScale + gframe.frame.minX, y: map.center.y / zoomScale + gframe.frame.minY)
        device.Scale(scale: zoomScale)
        map.addSubview(device)
        deviceList.append(device)
        return device
    }
    
    func AddDevice(types:[GraphicEditorUtils.DeviceType],gframe:GraphicEditorUtils.GraphicFrame)->[GraphicBaseDevice]{
        
        var list = [GraphicBaseDevice]()
        for i in 0..<types.count{
            var device:GraphicBaseDevice!
            switch types[i] {
            case .Light:
                device = GraphicLight.init(frame: gframe.frame)
            case .Beacon:
                device = GraphicBeacon.init(frame: gframe.frame)
                break
            case .Sensor:
                device = GraphicSensor.init(frame: gframe.frame)
                break
            case .Gateway:
                device = GraphicGateway.init(frame: gframe.frame)
                break
            default:
                device = GraphicBaseDevice.init(frame: gframe.frame)
                break
            }
            let zoneSize = CGSize.init(width: device.gWidth / GraphicEditorUtils.BASE_SIZE.width + 1, height: device.gHeight / GraphicEditorUtils.BASE_SIZE.height + 1)
            //device.gFrame = gframe
            //先設定原點為中心點再移動至grame座標
            var perLine:Int = Int(gframe.width / zoneSize.width)
            perLine = max(perLine, 1)
            let x = CGFloat(i % perLine) * (zoneSize.width)
            let y = CGFloat(i/perLine) * (zoneSize.height)
            let position = GraphicEditorUtils.GraphicFrame.init(x: gframe.x + x , y: gframe.y + y, width: device.DEFAULT_SIZE.width, height: device.DEFAULT_SIZE.height)
            device.gFrame = position
            device.frame.origin = CGPoint.init(x: map.center.x / zoomScale + position.frame.minX, y: map.center.y / zoomScale + position.frame.minY)
            device.Scale(scale: zoomScale)
            map.addSubview(device)
            deviceList.append(device)
            list.append(device)
        }
        return list
    }
    
    
    func GetZoomScale()->CGFloat{
        return zoomScale
    }
    
    func SetZoomScale(scale:CGFloat){
        if scale < GraphicEditorUtils.ZOOM_MIN_SCALE  || scale > GraphicEditorUtils.ZOOM_MAX_SCALE{
            return
        }
        //print(scale)
        isZoom = true
        zoomScale = scale
        scrollview?.setZoomScale(zoomScale, animated: false)
        isZoom = false
        
        let min:CGFloat = 5
        if GraphicEditorUtils.BASE_SIZE.width * zoomScale < min{
            if let image = GraphicEditorUtils.BackgroundImage(size: CGSize.init(width: min/zoomScale, height: min/zoomScale),lineWidth: 1/zoomScale)?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left:0, bottom: 0, right: 0), resizingMode: .tile){
                mapBackground.backgroundColor = UIColor.init(patternImage: image)
            }
        }else{
            if let image = GraphicEditorUtils.BackgroundImage(size: GraphicEditorUtils.BASE_SIZE,lineWidth: 1/zoomScale)?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left:0, bottom: 0, right: 0), resizingMode: .tile){
                mapBackground.backgroundColor = UIColor.init(patternImage: image)
            }
        }
        
        let mapSize = CGSize.init(width: mapSize.width * GraphicEditorUtils.BASE_SIZE.width * zoomScale, height: mapSize.height * GraphicEditorUtils.BASE_SIZE.height * zoomScale)
        if mapSize.width > frame.width && mapSize.height > frame.height{
            //scrollview.contentOffset = CGPoint(x: mapSize.width/2 - frame.width / 2, y: mapSize.height/2 - frame.height / 2)
        }else{
            scrollview.contentOffset = .zero
        }
        
        for item in deviceList{
            item.Scale(scale: zoomScale)
        }
        //print(scrollview.contentSize)
    }

    //每幀更新可見範圍，如果移動物件在邊緣也要移動(操作體感)
    @objc func update(){
        if movePoint != .zero,let item = moveItem{
            //print("update movePoint\(movePoint)")
            let offset = scrollview.contentOffset
            var x = offset.x + movePoint.x
            if x < 0 {
                x = 0
                movePoint.x = 0
            }else if x > scrollview.contentSize.width - scrollview.width{
                x = scrollview.contentSize.width - scrollview.width
                movePoint.x = 0
            }
            var y = offset.y + movePoint.y
            if y < 0 {
                y = 0
                movePoint.y = 0
            }else if y > scrollview.contentSize.height - scrollview.height{
                y = scrollview.contentSize.height - scrollview.height
                movePoint.y = 0
            }
            //print("update offset\(CGPoint.init(x: x, y: y))")
            scrollview.setContentOffset(CGPoint.init(x: x, y: y), animated: true)
            
            //如果是小幅位移 操作的物件也要跟著位移
            if abs(movePoint.x) > GraphicEditorUtils.BASE_SIZE.width{
            }else{
                item.frame.origin.x += movePoint.x
            }
            if abs(movePoint.y) > GraphicEditorUtils.BASE_SIZE.height{
            }else{
                item.frame.origin.y += movePoint.y
            }
            
            movePoint = countScrollviewOffset(direction: movePoint)
        }
    }
    
    //計算滑動方向
    private func countScrollviewOffset(direction:CGPoint)->CGPoint{
        //print("scrollview.contentOffset\(scrollview.contentOffset)")
        if let item = moveItem{
            let scrollMinX = scrollview.contentOffset.x
            let scrollMaxX = scrollview.contentOffset.x  + scrollview.width
            let scrollMinY = scrollview.contentOffset.y
            let scrollMaxY = scrollview.contentOffset.y + scrollview.height
            
            let itemMinX = item.x * zoomScale
            let itemMaxX = (item.x + item.width) * zoomScale
            let itemMinY = item.y * zoomScale
            let itemMaxY = (item.y + item.height) * zoomScale
            
            var nextPoint:CGPoint = .zero
            //print("item.x\(item.x)")
            //print("scrollMinX\(scrollMinX)")
            if item.width * zoomScale > scrollview.width{
                //物體太大 scollview不滾動
                nextPoint.x = 0
            }else if direction.x<0{
                if itemMinX < scrollMinX{
                    nextPoint.x = -(scrollMinX - itemMinX)
                }else if itemMinX - GraphicEditorUtils.BASE_SIZE.width <= scrollMinX{
                    nextPoint.x = -GraphicEditorUtils.BASE_SIZE.width
                }
            }else if direction.x>0{
                if itemMaxX > scrollMaxX{
                    nextPoint.x = itemMaxX - scrollMaxX
                }else if itemMaxX + GraphicEditorUtils.BASE_SIZE.width >= scrollMaxX{
                    nextPoint.x = GraphicEditorUtils.BASE_SIZE.width
                }
            }
            //print("item.y\(item.y)")
            //print("minY\(minY)")
            //Y
            if item.height * zoomScale > scrollview.height{
                //物體太大 scollview不滾動
                nextPoint.y = 0
            }else if direction.y<0{
                if itemMinY < scrollMinY{
                    nextPoint.y =  -(scrollMinY - itemMinY)
                }else if itemMinY - GraphicEditorUtils.BASE_SIZE.height <= scrollMinY{
                    nextPoint.y = -GraphicEditorUtils.BASE_SIZE.height
                }
            }else if direction.y>0{
                if itemMaxY > scrollMaxY{
                    nextPoint.y = itemMaxY - scrollMaxY
                }else if itemMaxY + GraphicEditorUtils.BASE_SIZE.height >= scrollMaxY{
                    nextPoint.y = GraphicEditorUtils.BASE_SIZE.height
                }
            }
            //print("countScrollviewOffset\(nextPoint)")
            return nextPoint
        }
        return .zero
    }
    
    func GetMapRect()->GraphicEditorUtils.GraphicFrame{
        
        let unit = 1 / GraphicEditorUtils.BASE_SIZE.width / zoomScale
        let x = scrollview.contentOffset.x * unit - mapSize.width / 2
        let y = scrollview.contentOffset.y * unit - mapSize.height / 2
            
        return GraphicEditorUtils.GraphicFrame.init(x: x, y: y, width: scrollview.width * unit, height: scrollview.height * unit)
    }
}

extension GraphicMap:UIScrollViewDelegate{
    
    // 開始滑動時
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }

    // 滑動時
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scrollViewDidScroll")
        //print(scrollview.contentOffset)
    }

    // 結束滑動時
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView,
      willDecelerate decelerate: Bool) {
        
    }
    // 縮放的元件
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return isZoom ? map : nil
    }

    // 開始縮放時
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
    

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {

        // 縮放元件時 會將 contentSize 設為這個元件的尺寸
        // 會導致 contentSize 過小而無法滑動
        // 所以縮放完後再將 contentSize 設回原本大小
        //scrollView.contentSize = CGSize.init(width: mapWidth * BASE_SIZE.width, height: mapHight * BASE_SIZE.height)
    }
}


extension GraphicMap:GraphicBaseAbstractDelegate{
    func OnItemClick(item: GraphicBaseAbstract) {
        //zone 單選  device多選
        if item is GraphicBaseDevice{
            if let first = focusList.first,first is GraphicBaseZone{
                for i in focusList{
                    i.SetFocus(isSelect: false)
                }
                focusList = []
            }
        }else{
            for i in focusList{
                i.SetFocus(isSelect: false)
            }
            focusList = []
        }
        
        
        if item == map{
        
        }else if let index = focusList.firstIndex(of: item){
            focusList.remove(at: index)
            item.SetFocus(isSelect: false)
        }else{
            focusList.append(item)
            map.bringSubviewToFront(item)
            item.SetFocus(isSelect: true)
        }
        
        if focusList.first is GraphicBaseZone{
            scrollview.isScrollEnabled = false
        }else{
            scrollview.isScrollEnabled = true
        }
        
        del?.OnEditorClick(item: item)
    }
    
    func OnItemDrag(item: GraphicBaseAbstract,recognizer:UIPanGestureRecognizer) {
        if recognizer.state == .ended{
            movePoint = .zero
            return
        }
        
        if focusList.contains(item){
            moveItem = item
            let translation = recognizer.translation(in: map)
            //print("translation\(translation)")
            let offset = countScrollviewOffset(direction: translation)
            //print("offset\(offset)")
            if offset != .zero{
                movePoint = offset
            }
            del?.OnItemDrag(item: item, recognizer: recognizer)
        }else{
            if scrollview.contentSize.width < scrollview.width || scrollview.contentSize.height < scrollview.height{
                return
            }
            
            //移動scrollview
            let offset = scrollview.contentOffset
            let translation = recognizer.translation(in: recognizer.view?.superview)
            let newCenter = CGPoint.init(x: offset.x - translation.x * zoomScale, y: offset.y - translation.y * zoomScale)
            scrollview.setContentOffset(newCenter, animated: false)
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view?.superview)
        }
        
    }
    
    func OnEditorClick(item: GraphicBaseAbstract) {
        del?.OnEditorClick(item: item)
    }
    
    func OnEditorPowerClick(item: GraphicBaseAbstract, isOn: Bool) {
        del?.OnEditorPowerClick(item: item, isOn: isOn)
    }
}
