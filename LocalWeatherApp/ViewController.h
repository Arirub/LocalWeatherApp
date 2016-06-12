//
//  ViewController.h
//  LocalWeatherApp
//
//  Created by Ariane Rubio on 11/6/16.
//  Copyright © 2016 Ariane Rubio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Geolocation.h"

@interface ViewController : UIViewController
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property(retain)  Geolocation* geo;
- (IBAction)checkWeather:(id)sender;

@end

