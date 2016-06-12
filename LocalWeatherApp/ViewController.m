//
//  ViewController.m
//  LocalWeatherApp
//
//  Created by Ariane Rubio on 11/6/16.
//  Copyright © 2016 Ariane Rubio. All rights reserved.
//

#import "ViewController.h"
#import "Geolocation.h"
#import "WeatherTableViewController.h"
#import "AppDelegate.h"

#define METERS_MILE 1609.344
#define METERS_FEET 3.28084


@interface ViewController ()<CLLocationManagerDelegate>
@property (strong) NSMutableArray *locations;

@end

@implementation ViewController
@synthesize geo;

-(id)init
{
    self = [super init];
    if(self)
    {
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mapView setShowsUserLocation:YES];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    // we have to setup the location manager with permission in later iOS versions
    if ([[self locationManager] respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [[self locationManager] requestWhenInUseAuthorization];
    }
    
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
    //[self.locationManager startMonitoringSignificantLocationChanges];
    self.geo= [[Geolocation alloc] init];
    
    
}
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if(locations!=nil){
        CLLocation *location = locations.lastObject;
        
        
        
        [geo setLatitude:[NSString stringWithFormat:@"%.6f", location.coordinate.latitude]];
        [geo setLongitude:[NSString stringWithFormat:@"%.6f", location.coordinate.longitude]];
        //NSLog(@" latitude %@",[geo latitude]);
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2*METERS_MILE, 2*METERS_MILE);
        [[self mapView] setRegion:viewRegion animated:YES];
        
    }
    
    
}
-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Error %@",[error localizedDescription]);
}


- (IBAction)checkWeather:(id)sender {
    
    NSString *radiusValue;
    if([geo radius] ==nil){
        radiusValue=@"10000";
    }else{
        radiusValue=[geo radius];
    }
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newLocation= [NSEntityDescription insertNewObjectForEntityForName:@"GeolocationEntity" inManagedObjectContext:context];
    [newLocation setValue:[geo latitude] forKey:@"latitude"];
    [newLocation setValue:[geo longitude]  forKey:@"longitude"];
    [newLocation setValue:radiusValue forKey:@"radius"];
    [self performSegueWithIdentifier:@"idSegueTableView" sender:self];
    NSLog(@"44444444444444444444radius %@ ",radiusValue);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)sliderChange:(UISlider *)sender {
}
- (IBAction)changeRadius:(id)sender {
    UISlider *slider= (UISlider *)sender;
    int distanceInt=(int)slider.value;
    self.labelDistance.text=[NSString stringWithFormat:@"%d", distanceInt];
    [geo setRadius:[NSString stringWithFormat:@"%d", distanceInt*1000]];
    // NSLog(@"i am here with raidus %d",distanceInt);
}
@end
