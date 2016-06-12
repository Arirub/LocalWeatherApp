//
//  GeolocationEntity+CoreDataProperties.h
//  LocalWeatherApp
//
//  Created by Ariane Rubio on 12/6/16.
//  Copyright © 2016 Ariane Rubio. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GeolocationEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface GeolocationEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *latitude;
@property (nullable, nonatomic, retain) NSString *longitude;
@property (nullable, nonatomic, retain) NSString *radius;

@end

NS_ASSUME_NONNULL_END
