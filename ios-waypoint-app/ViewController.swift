import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    let mainMapScreen: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    @objc let searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "searchButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc let routeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "routeButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "resetButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    var annotationsArray = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainMapScreen.delegate = self
        
        setConstraints()
        
        searchButton.addTarget(self, action: #selector(searchAddressButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
    }

    @objc func searchAddressButtonTapped() {
        alertAddAdresse(title: "Enter location", placeholder: nil) { [self] (text) in
            setupPlaceMark(addressPlace: text!)
        }
    }
    
    @objc func routeButtonTapped() {
        
        for index in 0...annotationsArray.count - 2 {
            
            createDirectionRequest(startCoordinate: annotationsArray[index].coordinate, destinationCoordinate: annotationsArray[index+1].coordinate)
            
        }
        mainMapScreen.showAnnotations(annotationsArray, animated: true)
    }
    
    @objc func resetButtonTapped() {
        mainMapScreen.removeOverlays(mainMapScreen.overlays)
        mainMapScreen.removeAnnotations(mainMapScreen.annotations)
        annotationsArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        resetButton.isHidden = true
        
    }
    
    private func setupPlaceMark(addressPlace: String) {
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(addressPlace) { [self] (placemarks, error) in
            
            if let error = error {
                print ("Geocoding failed with error: \(error.localizedDescription)")
                alertError(title: "You're not put an address", message: nil)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(addressPlace)"
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            annotationsArray.append(annotation)
            
            if annotationsArray.count > 1 {
                routeButton.isHidden = false
            }
            
            if annotationsArray.count > 0 {
                resetButton.isHidden = false
            }
            mainMapScreen.showAnnotations(annotationsArray, animated: true)
        }
    }
    
    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: startLocation)
        directionRequest.destination = MKMapItem(placemark: destinationLocation)
        directionRequest.transportType = .walking
        directionRequest.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: directionRequest)
        direction.calculate { response, error in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.alertError(title: "error", message: "Can't find a location")
                return
            }
            
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mainMapScreen.addOverlay(minRoute.polyline)
            
        }
        
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}

extension ViewController {
        
        func setConstraints() {
            
            view.addSubview(mainMapScreen)
            NSLayoutConstraint.activate([
                mainMapScreen.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                mainMapScreen.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                mainMapScreen.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                mainMapScreen.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            ])
            
            mainMapScreen.addSubview(searchButton)
            NSLayoutConstraint.activate([
                searchButton.topAnchor.constraint(equalTo: mainMapScreen.topAnchor, constant: 80),
                searchButton.trailingAnchor.constraint(equalTo: mainMapScreen.trailingAnchor, constant: -55),
                searchButton.heightAnchor.constraint(equalToConstant: 45),
                searchButton.widthAnchor.constraint(equalToConstant: 300)
            ])
            
            mainMapScreen.addSubview(routeButton)
            NSLayoutConstraint.activate([
                routeButton.bottomAnchor.constraint(equalTo: mainMapScreen.bottomAnchor, constant: -60),
                routeButton.leadingAnchor.constraint(equalTo: mainMapScreen.leadingAnchor, constant: 30),
                routeButton.heightAnchor.constraint(equalToConstant: 55),
                routeButton.widthAnchor.constraint(equalToConstant: 55)
            ])
            
            mainMapScreen.addSubview(resetButton)
            NSLayoutConstraint.activate([
                resetButton.bottomAnchor.constraint(equalTo: mainMapScreen.bottomAnchor, constant: -50),
                resetButton.trailingAnchor.constraint(equalTo: mainMapScreen.trailingAnchor, constant: -30),
                resetButton.heightAnchor.constraint(equalToConstant: 50),
                resetButton.widthAnchor.constraint(equalToConstant: 50)
            ])
            
    }
}


