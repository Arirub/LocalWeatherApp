//
//  WeatherTableViewController.h
//  LocalWeatherApp
//
//  Created by Ariane Rubio on 11/6/16.
//  Copyright © 2016 Ariane Rubio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geolocation.h"
#import "ViewController.h"

@interface WeatherTableViewController : UITableViewController

@property (nonatomic) Geolocation* geolocview;
@property (nonatomic) NSString * prueba;

@end
