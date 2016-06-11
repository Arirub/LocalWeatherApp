//
//  WeatherTableViewCell.h
//  LocalWeatherApp
//
//  Created by Ariane Rubio on 11/6/16.
//  Copyright © 2016 Ariane Rubio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelTemp;
@property (strong, nonatomic) IBOutlet UILabel *labelTempMin;
@property (strong, nonatomic) IBOutlet UILabel *labelTempMax;

@end
