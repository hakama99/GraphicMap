# GraphiciMap

## 圖形化編輯器

* 1.提供產生基本物件(可擴充)
* 2.Zone可放大縮小移動,Device僅可移動
* 3.選擇Zone時無法移動地圖，避免縮放導致操作困難
* 4.提供儲存及讀檔，座標為正中央(0,0)，x向右遞增，y向下遞增

![截圖 2021-06-24 下午5 27 58](https://user-images.githubusercontent.com/59221388/123239364-dcc52500-d511-11eb-970b-5ada8bafb811.png)

![截圖 2021-06-24 下午5 29 20](https://user-images.githubusercontent.com/59221388/123239378-df277f00-d511-11eb-8217-b8ec68a69e4a.png)

## 範例:

### createmap

產生自定義大小地圖


### createdesample

產生各種基本物件，目前有
* Zone
  * 圓形+編輯器
  * 方形+編輯器
  * 圓型
  * 方型
  * label標籤

* Device(目前僅圖片不同，可自定義)
  * Light
  * Sensor
  * Gateway
  * Beacon


### createdeviceinzone

產生Device放進Zone裏面，會計算目前內部裝置相對位置顯示
要操作zone內的裝置，應另外產生地圖(當成zone)，產生內部裝置物件在地圖上

### zoomin,zoomout

放大縮小

### cleanmap

清空地圖


### saveData

儲存物件名稱位置

### loadData

讀取資料產生物件


## Protocol
 
    //按下物件回傳
    @objc func OnItemClick(item:GraphicBaseAbstract)
    //物件拖拉回傳
    @objc func OnItemDrag(item:GraphicBaseAbstract,recognizer:UIPanGestureRecognizer)
    //控制器按下回傳
    @objc func OnEditorClick(item:GraphicBaseAbstract)
    //控制器開關回傳
    @objc func OnEditorPowerClick(item:GraphicBaseAbstract,isOn:Bool)


## Class Diagram

    GraphicBaseAbstract -> GraphicBaseZone -> 實作Zone
                        -> GraphicBaseDevice -> 實作Device
                    
    GraphicBaseEditorView -> 實作控制視窗

