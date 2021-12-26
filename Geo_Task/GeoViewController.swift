//
//  ViewController.swift
//  Geo_Task
//
//  Created by Asset Ryskul on 24.12.2021.
//

import UIKit
import MapKit

class GeoViewController: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    let baseUrl = "https://waadsu.com/api/russia.geo.json"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set initial location in Moscow
        let initialLocation = CLLocation(latitude: 55.751244, longitude: 37.618423)
        mapView.centerToLocation(initialLocation)
        mapView.delegate = self
        performRequest()
        
        
    }

    func parseGeoJSON(_ data: Data?)  -> [MKOverlay] {

        guard let safeData = data
        else {
            fatalError("Unable to decode geoJSON")
        }
        var geoJSON = [MKGeoJSONObject]()
        
        do {
            geoJSON = try MKGeoJSONDecoder().decode(safeData)
        } catch {
            debugPrint(error)
        }
        var overlays = [MKOverlay]()
        for item in geoJSON {
            if let feature = item as? MKGeoJSONFeature {
                for geo in feature.geometry {
                    if let polygon = geo as? MKMultiPolygon {
                        overlays.append(polygon)
                    }
                }
            }
        }
        return overlays
    }
    
    func performRequest() {
        if let url = URL(string: baseUrl) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error as Any)
                    return
                }
                if let safeData = data {
                    let overlays = self.parseGeoJSON(safeData)
                    DispatchQueue.main.async {
                        self.mapView.addOverlays(overlays)
                    }
                    
                }
            }
            task.resume()
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(overlay: polygon)
            renderer.fillColor = UIColor.lightGray.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.red
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
}

extension MKMapView {
    
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 100000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

