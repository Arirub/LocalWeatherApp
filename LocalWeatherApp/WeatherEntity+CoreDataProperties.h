//
//  WeatherEntity+CoreDataProperties.h
//  LocalWeatherApp
//
//  Created by Ariane Rubio on 12/6/16.
//  Copyright © 2016 Ariane Rubio. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WeatherEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeatherEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *city;
@property (nullable, nonatomic, retain) NSString *temp;
@property (nullable, nonatomic, retain) NSString *tempMin;
@property (nullable, nonatomic, retain) NSString *tempMax;
@property (nullable, nonatomic, retain) NSString *weatherDescription;

@end

NS_ASSUME_NONNULL_END
