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
    CLLocation *location = locations.lastObject;
    
    self.geo= [[Geolocation alloc] init];
    
    [geo setLatitude:[NSString stringWithFormat:@"%.6f", location.coordinate.latitude]];
    [geo setLongitude:[NSString stringWithFormat:@"%.6f", location.coordinate.longitude]];
    NSLog(@" latitude %@",[geo latitude]);
    
    
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    /*NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new managed object
    NSManagedObject *newLocation= [NSEntityDescription insertNewObjectForEntityForName:@"GeolocationEntity" inManagedObjectContext:context];
    [newLocation setValue:[NSString stringWithFormat:@"%.6f", location.coordinate.latitude] forKey:@"latitude"];
    [newLocation setValue:[NSString stringWithFormat:@"%.6f", location.coordinate.longitude] forKey:@"longitude"];
    [newLocation setValue:@"10000" forKey:@"radio"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
       }
        
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"GeolocationEntity"];
        self.locations = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
        
        */
        
    
    
    
    
    
    
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2*METERS_MILE, 2*METERS_MILE);
    [[self mapView] setRegion:viewRegion animated:YES];
    
    
}



- (IBAction)checkWeather:(id)sender {
    //WeatherTableViewController tableView=[segue idSegueTableView];
 //   [self performSegueWithIdentifier:@"idSegueTableView" sender:self];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new managed object
    NSManagedObject *newLocation= [NSEntityDescription insertNewObjectForEntityForName:@"GeolocationEntity" inManagedObjectContext:context];
    [newLocation setValue:[geo latitude] forKey:@"latitude"];
    [newLocation setValue:[geo longitude]  forKey:@"longitude"];
    [newLocation setValue:@"10000" forKey:@"radius"];
    [self performSegueWithIdentifier:@"idSegueTableView" sender:self];
}
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"idSegueTableView"] ){
        WeatherTableViewController *vc = (WeatherTableViewController *)  segue.destinationViewController;
        //[vc setLocation:geoLoc];   //in example someProperty is a BOOL
        vc.prueba=@"aaaaaaaaaaaaaaaaaaaaa";
    }
    else {
        //Do whatever accordingly
        
    }
    
    
}*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
