//
//  Geolocation.h
//  LocalWeatherApp
//
//  Created by Ariane Rubio on 11/6/16.
//  Copyright © 2016 Ariane Rubio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Geolocation : NSObject

@property (nonatomic,retain) NSString *latitude;
@property (nonatomic,retain) NSString *longitude;
@property (nonatomic,retain) NSString *radius;

@end
