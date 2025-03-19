import MapKit

extension ViewController {
    func setupPlaceMark(addressPlace: String) {
        
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
    
    func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
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
