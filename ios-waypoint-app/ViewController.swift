import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    let mapview: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConstraints()
        
    }
}
extension ViewController {
        
        func setConstraints() {
            
            view.addSubview(mapview)
            NSLayoutConstraint.activate([
                mapview.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                mapview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                mapview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                mapview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            ])
    }
}


