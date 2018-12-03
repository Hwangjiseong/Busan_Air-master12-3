//
//  ViewController.swift
//  Busan_Air
//
//  Created by D7703_03 on 2018. 12. 1..
//  Copyright © 2018년 D7703_03. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, XMLParserDelegate {
    
    @IBOutlet weak var myMapView: MKMapView!
    
    var annotation: Airdata?
    var annotations: Array = [Airdata]()
    
    var item:[String:String] = [:]  // item[key] => value
    var items:[[String:String]] = []
    var currentElement = ""
    
    var tPM10: String?
    var address: String?
    var lat: String?
    var long: String?
    var loc: String?
    var dLat: Double?
    var dLong: Double?
    
    // 1시간 마다 호출위해 타이머 객체 생성
    var timer = Timer()
    var currentTime: String?
    
    // 광복동, 초량동
    let addrs:[String:[String]] = [
        "201111" : ["중구 남포동 구덕로 지하 12", "35.098041", "129.035033", "남포역 대합실"],
        "201191" : ["부산진구 부전동 260-22", "35.1583462", "129.0582437"," 1호선 대합실"],
        "201193" : ["부산진구 부전2동 중앙대로 720-1", "35.1570747", "129.0583408", "서면역 1호선 승강장"],
        "202191" : ["부산진구 부전동 257-63", "35.1570747", "129.0583408"," 2호선 대합실"],
        "202192" : ["부산진구 부전1동 가야대로 789", "35.1579012", "129.0569016", "2호선 승강장"],
        "202271" : ["괘법동", "35.1625397", "128.985913", "사상역 대합실"],
        "203011" : ["수영구 수영로 576", "35.167273", "129.115664", "한국환경공단", "도시대기", "주거지역"],
        "203051" : ["연산동", "35.1865484", "129.0780535", "연산연 대합실"],
        "203091" : ["온천3동", "35.2054534", "129.065853", "미남역 대합실"],
        "203131" : ["부산광역시 덕천2동", "35.2113369", "129.0036468", "덕천역 대합실"]
    ]
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "부산 실내미세먼지 지도"
        // Do any additional setup after loading the view, typically from a nib.
        
        myParse()
        timer = Timer.scheduledTimer(timeInterval: 60*60, target: self, selector: #selector(myParse), userInfo: nil, repeats: true)
        
        
        
        // Map
        myMapView.delegate = self
        
        //  초기 맵 region 설정
        zoomToRegion()
        
        for item in items {
            let dSite = item["areaIndex"]
            print("areaIndex = \(String(describing: dSite))")
            
            // 추가 데이터 처리
            for (key, value) in addrs {
                if key == dSite {
                    address = value[0]
                    lat = value[1]
                    long = value[2]
                    loc = value[3]
                    dLat = Double(lat!)
                    dLong = Double(long!)
                }
            }
            
            // 파싱 데이터 처리
            let dPM10 = item["pm10"]
            
            print("dMP10 = \(String(describing: dPM10))")
            
            
            
            //let subtitleOut =  "PM10 " + vPM10Cai! + " " + dPM10! + " ug/m3 "
            
            annotation = Airdata(coordinate: CLLocationCoordinate2D(latitude: dLat!, longitude: dLong!), title: loc!,
                                 subtitle: "부산시 " + address!, pm10: dPM10!)
            
            annotations.append(annotation!)
        }
        
        print("annotations = \(annotations)")
        // 지도의 중심점, 반경 등(zoomToRegion)이 없이도 모든 pin을 포함하여 지도가 보여질 수 있도록 함
        //myMapView.showAnnotations(annotations, animated: true)
        
        // 지도의 중심점, 반경 등(zoomToRegion)이 반드시 필요함
        myMapView.addAnnotations(annotations)
    }
    
    @objc func myParse() {
        // XML Parsing
        let key = "cLHR7K%2BU8sG3j6B0ULITYNuZPyKB1PYG2USwW3dYmJ5bzi%2FCc3CTAPzYOlnenW%2BUBUlbjpFtnF%2F6JIiRe3Ygmw%3D%3D"
        let strURL = "http://opendata.busan.go.kr/openapi/service/IndoorAirQuality/getIndoorAirQualityByStation?ServiceKey=\(key)&numOfRows=21"
        
        if let url = URL(string: strURL) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                
                if (parser.parse()) {
                    print("parsing success")
                    
                    // 파싱이 끝난시간 시간 측정
                    let date: Date = Date()
                    let dayTimePeriodFormat = DateFormatter()
                    dayTimePeriodFormat.dateFormat = "YYYY/MM/dd HH시"
                    currentTime = dayTimePeriodFormat.string(from: date)
                    for item in items {
                        print("item pm10 = \(item["pm10"]!)")
                    }
                    
                } else {
                    print("parsing fail")
                }
            } else {
                print("url error")
            }
        }
        
    }
    
    func zoomToRegion() {
        let location = CLLocationCoordinate2D(latitude: 35.180100, longitude: 129.081017)
        let span = MKCoordinateSpan(latitudeDelta: 0.27, longitudeDelta: 0.27)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
    }
    
    
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Leave default annotation for user location
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseID = "MyPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if annotationView == nil {
            let pin = MKPinAnnotationView(annotation: annotation,
                                          reuseIdentifier: reuseID)
            //            pin.image = UIImage(named: "marker-30")
            pin.isEnabled = true
            pin.canShowCallout = true
            
            let castAirdata = annotation as! Airdata
            
            
            let label = UILabel(frame: CGRect(x: -2, y: 12, width: 30, height: 30))
            label.textColor = UIColor.orange
            //            label.text = annotation.id // set text here
            
            //let castBusanData = annotation as! BusanData
            
            //label.text = castAirdata.pm10
            label.text = castAirdata.pm10!
            print(castAirdata.pm10!)
            pin.addSubview(label)
            annotationView = pin
            
            
        } else {
            annotationView?.annotation = annotation
        }
        
        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
        return annotationView
    }
    
    // rightCalloutAccessoryView를 눌렀을때 호출되는 delegate method
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let viewAnno = view.annotation as! Airdata // 데이터 클래스로 형변환(Down Cast)
        let vPM10 = viewAnno.pm10
        let vStation = viewAnno.title
        
        
        //let mTitle = "미세먼지(PM 10)  \(tPM10!) (\(vPM10!) ug/m3)"
        
        
        
        let ac = UIAlertController(title: vStation! + " 대기질 측정소", message: nil, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "측정시간  " + currentTime! , style: .default, handler: nil))
        
        ac.addAction(UIAlertAction(title: "PM10 : " + vPM10!, style: .default, handler: nil))
        
        //ac.addAction(UIAlertAction(title: mTitle, style: .default, handler: nil))
        ac.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
        self.present(ac, animated: true, completion: nil)
        
    }
    
    // XML Parsing Delegate 메소드
    // XMLParseDelegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        
        // tag 이름이 elements이거나 item이면 초기화
        if elementName == "items" {
            items = []
        } else if elementName == "item" {
            item = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        //        print("data = \(data)")
        if !data.isEmpty {
            item[currentElement] = data
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            items.append(item)
        }
    }
}
