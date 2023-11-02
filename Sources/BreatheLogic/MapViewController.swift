//
//  MapViewController.swift
//  Breathe
//
//  Created by Jacob Trentini on 1/27/23.
//

import SwiftUI
import MapKit
import GameplayKit
import BreatheShared

public struct MapViewRepresentable: UIViewControllerRepresentable {
    public typealias UIViewControllerType = MapViewController
    @EnvironmentObject private var appSharedModel: AppSharedModel
    @State public var mapViewController: MapViewController!
    
    public init() {
        _mapViewController = State(initialValue: MapViewController())
    }
    
    public func makeUIViewController(context: Context) -> MapViewController {
        mapViewController.appSharedModel = appSharedModel
        return mapViewController
    }
    
    public func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        uiViewController.appSharedModel = appSharedModel
        uiViewController.mapView.mapType = appSharedModel.mapType.wrappedValue.mapKitType
    }
}

public class MapViewController: UIViewController {
    fileprivate var mapView = MKMapView()
    let maxiumumAnnotations = 100
    private var deviceScale: CGFloat = .zero
    public var appSharedModel = AppSharedModel()
    public static let scaleUp = CABasicAnimation(keyPath: "transform.scale")
    
    private var wildfireAnnotations: [WildfireAnnotation] = []
    private var airNowAnnotations:   [AirNowAnnotation]   = []
    
    private var airQualityTileRenderer: MKTileOverlayRenderer?
    
    private var hasAddedAirQualityOverlay = false
    private var hasAddedWildfires = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
                
        setUpMapView()
        
        LocationsHelper.shared.mapView = mapView
        
        deviceScale = view.window?.windowScene?.screen.scale ?? 0.0
        
        MapViewController.scaleUp.fromValue = 0.7
        MapViewController.scaleUp.toValue = 1
        MapViewController.scaleUp.duration = 0.07
        MapViewController.scaleUp.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
    }
    
    private func setUpMapView() {
        setUpAirQualityTileRenderer()
        
        mapView.frame = view.frame
        mapView.showsCompass      = false
        mapView.showsScale        = false
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        registerMapAnnotationViews()
        
        view.addSubview(mapView)
    }
}

extension MapViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard view.annotation is SensorAnnotation || view.annotation is CityAnnotation else { return }
        
        mapView.setCenter(view.annotation!.coordinate, animated: true)
        
        if let cityAnnotation = view.annotation as? CityAnnotation {
            appSharedModel.isCityLinkedSensorsSheetPresented.toggle()
            appSharedModel.cityPresented = cityAnnotation.city
        }

        view.displayPriority = .defaultHigh
        presentBottomSheet()
    }
    
    fileprivate func presentBottomSheet() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 1.0)

//        appSharedModel.selectedPanelBottomSheetPosition = .quarter
//        appSharedModel.mainBottomSheetPosition = .hidden(BottomSheetPositions.findMainSheetPosition(on: appSharedModel.mainBottomSheetPosition))
    }
    
    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard !(view is MKUserLocationView) else { return }
        
        view.displayPriority = .defaultLow
        view.layer.shadowOpacity = 0
        view.layer.shadowRadius = 0
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)")
        
        addAnnotationsInLayers()
        removeAnnotationsNotInSelectedLayers()
    }

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        switch annotation {
        case is SensorAnnotation:   return setupSensorAnnotation     (for: annotation as! SensorAnnotation,   on: mapView)
        case is CityAnnotation:     return setupCityAnnotation       (for: annotation as! CityAnnotation,     on: mapView)
        case is WildfireAnnotation: return setupWildfireAnnotation   (for: annotation as! WildfireAnnotation, on: mapView)
        case is AirNowAnnotation:   return setupAirNowAnnotation     (for: annotation as! AirNowAnnotation,   on: mapView)
        case is PollenAnnotation:   return setupPollenAnnotation     (for: annotation as! PollenAnnotation,   on: mapView)
        default:                    return setupDefaultAnnotationView(for: annotation)
        }
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return airQualityTileRenderer!
    }

    @MainActor
    public static func render(view: some View) -> UIImage {
        let imageRenderer = ImageRenderer(content: view)
        imageRenderer.scale = UIApplication.shared.keyWindow?.screen.scale ?? 1
        
        return imageRenderer.uiImage ?? .init()
    }
    
    func addAnnotationsInLayers() {
        Task {
            switch appSharedModel.selectedDataLayer.wrappedValue {
            case .airQuality: try await addSensors()
            case .pollen:               addPollen()
            }
        }
    }
    
    private func setUpAirQualityTileRenderer() {
        let overlay = MKTileOverlay(urlTemplate: "https://airquality.googleapis.com/v1/mapTypes/UAQI_INDIGO_PERSIAN/heatmapTiles/{z}/{x}/{y}?key=\(EnvironmentVariables.shared.googleCloudAPIKey)")
        
        overlay.canReplaceMapContent = false
        
        airQualityTileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)
        airQualityTileRenderer?.alpha = 0.5
    }
    
    func annotations<T: LayerInterface>(in layer: T) -> [MKAnnotation] {
        annotations(for: layer.associatedMKAnnotation)
    }
    
    func annotations(for annotation: MKAnnotation.Type) -> [MKAnnotation] {
        var annotations: [MKAnnotation] = []
        
        for mapViewAnnotation in mapView.annotations {
            if mapViewAnnotation.isKind(of: annotation) {
                annotations.append(mapViewAnnotation)
            }
        }
        
        return annotations
    }
    
    func removeWildfireAnnotations() {
        mapView.removeAnnotations(annotations(for: WildfireAnnotation.self))
        hasAddedWildfires = false
    }
    
    func removeAnnotationsNotInSelectedLayers() {
        let unincludedDataLayers = Set(Layers.allCases).subtracting([appSharedModel.selectedDataLayer.wrappedValue])
        
        let unincludedAnnotations = unincludedDataLayers.map { annotations(in: $0) }
        mapView.removeAnnotations(Array(unincludedAnnotations.joined()))
        
        switch appSharedModel.selectedDataLayer.wrappedValue {
        case .pollen:
            mapView.removeOverlays([airQualityTileRenderer!.overlay])
            hasAddedAirQualityOverlay = false
            
            removeWildfireAnnotations()
            
        default:          break
        }
        
        if !appSharedModel.airQualityLayer.wrappedValue.isWildfire && hasAddedWildfires {
            removeWildfireAnnotations()
        }
        
        if !appSharedModel.airQualityLayer.wrappedValue.isCities || appSharedModel.selectedDataLayer.wrappedValue != .airQuality {
            mapView.removeAnnotations(annotations(for: CityAnnotation.self))
        }
    }
    
    public func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        withAnimation {
            appSharedModel.tileOverlayRenderProgress = 0.3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.appSharedModel.tileOverlayRenderProgress != 1.0 {
                    self.appSharedModel.tileOverlayRenderProgress = 0.7
                }
            }
        }
    }
    
    public func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        withAnimation {
            appSharedModel.tileOverlayRenderProgress = 1.0
        }
    }
    
    public func addSensors() async throws {
        if !hasAddedAirQualityOverlay {
            mapView.addOverlay(airQualityTileRenderer!.overlay, level: .aboveRoads)
            hasAddedAirQualityOverlay.toggle()
        }
        
        if appSharedModel.airQualityLayer.wrappedValue.isWildfire && !hasAddedWildfires {
            hasAddedWildfires.toggle()
            try await addWildfires()
        }
        
        try await addCities()
    }
    
    public func addCities() async throws {
        guard appSharedModel.airQualityLayer.wrappedValue.isCities else { return }
        
        let newCities = try await BreatheServerAPI.shared.cities(topLeft: mapView.topLeftCoordinate(),
                                                                bottomRight: mapView.bottomRightCoordinate(),
                                                                excludedCities: Array(appSharedModel.cities.map { $0.reverseGeoCodedData.placeId }))
        
        guard appSharedModel.selectedDataLayer.wrappedValue == .airQuality else {
            print("Cancelling addCities() since user requested dataLayer changed")
            return
        }
        
        appSharedModel.cities.formUnion(newCities)
        
        if appSharedModel.cities.count >= 2 {
            let cities = GKRTree<CityAnnotation>(maxNumberOfChildren: appSharedModel.cities.count)
            for city in appSharedModel.cities {
                let point = vector_float2(Float(city.reverseGeoCodedData.coordinate.latitude), Float(city.reverseGeoCodedData.coordinate.longitude))
                
                cities.addElement(CityAnnotation(city: city),
                                  boundingRectMin: point,
                                  boundingRectMax: point,
                                  splitStrategy: .reduceOverlap)
            }
            
            appSharedModel.spatialCities = cities
            
            appSharedModel.tileOverlayRenderProgress = 0.3
            
            MapRender.calculateRenderOperation(spatialTree: appSharedModel.spatialCities, mapView: mapView, currentAnnotations: mapView.annotations, maximumAnnotationsToDisplay: maxiumumAnnotations) { addAnnotations, removeAnnotations, updatedAnnotations in
                self.mapView.removeAnnotations(removeAnnotations)
                
                for addAnnotation in addAnnotations {
                    self.mapView.addAnnotation(addAnnotation)
                }
                
                self.appSharedModel.tileOverlayRenderProgress = 0.7
                
                for (existing, updated) in updatedAnnotations {
                    if let annotationView = self.mapView.view(for: existing) {
                        if let oldReading = annotationView.annotation as? CityAnnotation {
                            oldReading.city = updated.city
                        }
                        
                        annotationView.prepareForDisplay()
                    }
                }
                
                self.appSharedModel.tileOverlayRenderProgress = 1.0
            }
        }
    }
    
    func addWildfires() async throws {
        let wildfires = try await BreatheServerAPI.shared.wildfires()
        wildfireAnnotations = wildfires.map { WildfireAnnotation(wildfire: $0) }
        
        mapView.addAnnotations(wildfireAnnotations)
    }
    
    func addPollen() {
        MapRender.calculateRenderOperation(spatialTree: appSharedModel.spatialSensors, mapView: mapView, currentAnnotations: mapView.annotations, maximumAnnotationsToDisplay: maxiumumAnnotations) { addAnnotations, removeAnnotations, updatedAnnotations in
            self.mapView.removeAnnotations(removeAnnotations)
            
            for addAnnotation in addAnnotations {
                self.mapView.addAnnotation(addAnnotation)
            }
            
            for (existing, updated) in updatedAnnotations {
                if let annotationView = self.mapView.view(for: existing) {
                    if let oldReading = annotationView.annotation as? PollenAnnotation {
                        oldReading.sensor = updated.sensor
                    }
                }
            }
        }
    }
}

// MARK: - Annotation Logic

extension MapViewController {
    private func registerMapAnnotationViews() {
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(SensorAnnotation  .self))
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CityAnnotation    .self))
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(WildfireAnnotation.self))
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(AirNowAnnotation  .self))
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(PollenAnnotation  .self))
    }
    
    private func setupDefaultAnnotationView(for annotation: MKAnnotation) -> MKAnnotationView {
        let reuseIdentifier = NSStringFromClass(type(of: annotation).self)
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
        annotationView.annotation = annotation
        return annotationView
    }
    
    private func setupSensorAnnotation(for annotation: SensorAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let annotationView = setupDefaultAnnotationView(for: annotation)
        
        annotationView.image = MapViewController.render(view: SensorDotView(airQuality: annotation.sensor.airQuality, radius: 35, textSize: 13))
        annotationView.collisionMode = .circle
        annotationView.displayPriority = .defaultLow
        annotationView.layer.add(MapViewController.scaleUp, forKey: nil)
        
        return annotationView
    }
    
    private func setupCityAnnotation(for annotation: CityAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let annotationView = setupDefaultAnnotationView(for: annotation)
        
        annotationView.image = MapViewController.render(view: CityView(airQuality: annotation.city.airQuality, locality: annotation.city.reverseGeoCodedData.name))
        annotationView.collisionMode = .rectangle
        annotationView.displayPriority = .defaultLow
        annotationView.layer.add(MapViewController.scaleUp, forKey: nil)
        
        return annotationView
    }
    
    private func setupWildfireAnnotation(for annotation: WildfireAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let annotationView = setupDefaultAnnotationView(for: annotation)
        
        annotationView.image = UIImage(named: "wildfire")
        annotationView.displayPriority = .defaultHigh
        annotationView.collisionMode = .circle
        annotationView.canShowCallout = true
        
        return annotationView
    }
    
    private func setupAirNowAnnotation(for annotation: AirNowAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let annotationView = setupDefaultAnnotationView(for: annotation)
        
        annotationView.image = UIImage(systemName: "sensor.tag.radiowaves.forward.fill")!.withTintColor(.red)
        annotationView.displayPriority = .defaultHigh
        let imageView = UIImageView(frame: .init(x: 0, y: 0, width: 70, height: 50))
        imageView.image = UIImage(named: "airnow")!
        annotationView.rightCalloutAccessoryView = imageView
        annotationView.canShowCallout = true
        
        return annotationView
    }
    
    private func setupPollenAnnotation(for annotation: PollenAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let annotationView = setupDefaultAnnotationView(for: annotation)
        
        annotationView.image = MapViewController.render(view: SensorDotView(airQuality: AirQuality(aqi: Int(annotation.sensor.pollen)), radius: 35, textSize: 13))
        annotationView.collisionMode = .circle
        annotationView.displayPriority = .defaultLow
        annotationView.layer.add(MapViewController.scaleUp, forKey: nil)
        
        return annotationView
    }
}

extension MKMapView {
    public func topLeftCoordinate() -> CLLocationCoordinate2D {
        convert(.zero, toCoordinateFrom: self)
    }

    public func bottomRightCoordinate() -> CLLocationCoordinate2D {
        convert(CGPoint(x: frame.width, y: frame.height), toCoordinateFrom: self)
    }
}
