//
//  WeatherEntity+CoreDataProperties.m
//  LocalWeatherApp
//
//  Created by Ariane Rubio on 12/6/16.
//  Copyright © 2016 Ariane Rubio. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WeatherEntity+CoreDataProperties.h"

@implementation WeatherEntity (CoreDataProperties)

@dynamic city;
@dynamic temp;
@dynamic tempMin;
@dynamic tempMax;
@dynamic weatherDescription;

@end
