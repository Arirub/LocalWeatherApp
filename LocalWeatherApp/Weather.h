//
//  Weather.h
//  LocalWeatherApp
//
//  Created by Ariane Rubio on 11/6/16.
//  Copyright © 2016 Ariane Rubio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather : NSObject

@property (nonatomic,retain) NSString *name;
@property (nonatomic) int temp;
@property (nonatomic) int temp_max;
@property (nonatomic) int temp_min;
@property (nonatomic,retain) NSString *description;

@end
