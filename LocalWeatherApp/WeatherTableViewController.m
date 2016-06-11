//
//  WeatherTableViewController.m
//  LocalWeatherApp
//
//  Created by Ariane Rubio on 11/6/16.
//  Copyright © 2016 Ariane Rubio. All rights reserved.
//

#import "WeatherTableViewController.h"
#import "Weather.h"
#import "WeatherTableViewCell.h"


@interface WeatherTableViewController ()<UITableViewDelegate, UITableViewDataSource>{
    
    NSMutableArray *cityWeather;
    Weather *weather;
}
@end

@implementation WeatherTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cityWeather=[[NSMutableArray alloc] init];
    [self loadVicinity];
    [self loadWeatherData :[self loadVicinity]];
    
    self.title=@"Weather of the nearest cities";
    
    //register Custom Table cell
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WeatherTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WeatherTableViewCell class])];
    
}

- (NSMutableDictionary *) loadVicinity{
    NSMutableDictionary *cityList=[[NSMutableDictionary alloc]init];
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=49.3757,8.6911&radius=10000&types=city_hall&key=AIzaSyAvCspNjtqsE7lg7KEbIUxtlDFAY-8QwSY"];
    
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSDictionary *jsonList=(NSDictionary*) [json valueForKey:@"results"];
    NSString *vicinity;
    
    for (NSDictionary *dic in jsonList){
        vicinity=(NSString*) [dic valueForKey:@"vicinity"];
        NSArray *city =[[NSArray alloc] init];
        city = [vicinity componentsSeparatedByString:@","];
        //NSString *t = [city objectAtIndex:1];
        
        NSString *trimmedCity = [[city objectAtIndex:1]stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceCharacterSet]];
        
        [cityList setObject:trimmedCity forKey:trimmedCity];
        NSLog(@"name es : %@", trimmedCity);
        
    }
    
    return cityList;
}
- (void) loadWeatherData:(NSMutableDictionary *)citiesList{
    
    for (id key in citiesList){
        weather=[[Weather alloc] init];
        
        NSError *error;
        NSString *name=[citiesList objectForKey:key];
        [weather setName:name];
        NSString *url_string = [NSString stringWithFormat: @"http://api.openweathermap.org/data/2.5/weather?q=%@&appid=46ae8cb55eaae08fd148a6a42f02e902", name];
        NSLog(@" urlstring es : %@", url_string);
        NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"data es : %@", json);
        [self readCitiesList:json];
        
    }
}
- (void) readCitiesList:(NSDictionary *)jsonList {
    
    NSDictionary *mainList =jsonList[@"main"];
    
    NSLog(@"mainList es : %@", mainList);
    
    NSString *temp =mainList[@"temp"];
    int tempInt=[self kelvinToCelsius:temp];
    [weather setTemp:tempInt];
    
    NSString *temp_max =mainList[@"temp_max"];
    int tempMaxInt=[self kelvinToCelsius:temp_max];
    [weather setTemp_max:tempMaxInt];
    NSLog(@"tempmax es : %@", temp_max);
    
    NSString *temp_min =mainList[@"temp_min"];
    int tempMinInt=[self kelvinToCelsius:temp_min];
    [weather setTemp_min:tempMinInt];
    NSLog(@"tempmin es : %@", temp_min);
    
    // NSDictionary *weatherJson=(NSDictionary*) [dic valueForKey:@"weather"];
    NSDictionary *weatherData =jsonList[@"weather"];
    //NSString *description =weatherData[@"description"];
    NSString *description;
    for (NSDictionary *mainDic in weatherData){
        description = (NSString*) [mainDic valueForKey:@"description"];
    }
    NSLog(@"description es : %@", description);
    [weather setDescription:description];
    
    //NSLog(@"weather es : %@", weather);
    [cityWeather addObject:weather];
    
}

-(int)kelvinToCelsius:(NSString *)kelvin {
    
    return (int)([kelvin doubleValue]-273.15);
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [cityWeather count];
}


 /*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

 
     Weather *dataWeather = [cityWeather objectAtIndex:indexPath.row];
     
     WeatherTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WeatherTableViewCell class]) forIndexPath:indexPath];
     cell.labelName.text=dataWeather.name;
     cell.labelDescription.text=[@"Weather: " stringByAppendingString:dataWeather.description];
     cell.labelTemp.text=[@"Temp: " stringByAppendingString:[NSString stringWithFormat:@"%d",dataWeather.temp]];
     cell.labelTempMin.text=[@"min: " stringByAppendingString:[NSString stringWithFormat:@"%d",dataWeather.temp_min]];
     cell.labelTempMax.text=[@"max: " stringByAppendingString:[NSString stringWithFormat:@"%d",dataWeather.temp_max]];
     
     return cell;
 
 return cell;
 }*/

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Weather *dataWeather = [cityWeather objectAtIndex:indexPath.row];
    
    WeatherTableViewCell *cell=[aTableView dequeueReusableCellWithIdentifier:NSStringFromClass([WeatherTableViewCell class]) forIndexPath:indexPath];
    cell.labelName.text=dataWeather.name;
    cell.labelDescription.text=[@"Weather: " stringByAppendingString:dataWeather.description];
    cell.labelTemp.text=[@"Temp: " stringByAppendingString:[NSString stringWithFormat:@"%d",dataWeather.temp]];
    cell.labelTempMin.text=[@"min: " stringByAppendingString:[NSString stringWithFormat:@"%d",dataWeather.temp_min]];
    cell.labelTempMax.text=[@"max: " stringByAppendingString:[NSString stringWithFormat:@"%d",dataWeather.temp_max]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
