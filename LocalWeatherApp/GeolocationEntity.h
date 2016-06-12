//
//  GeolocationEntity.h
//  LocalWeatherApp
//
//  Created by Ariane Rubio on 12/6/16.
//  Copyright © 2016 Ariane Rubio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface GeolocationEntity : NSManagedObject

@property (nonatomic, retain) NSString * latitude;
@property (nonatomic,retain) NSString * longitude;
@property (nonatomic,retain) NSString *  radius;


@end

NS_ASSUME_NONNULL_END

#import "GeolocationEntity+CoreDataProperties.h"
