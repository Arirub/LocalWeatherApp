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
#import "Geolocation.h"
#import "AppDelegate.h"
#import "GeolocationEntity.h"



@interface WeatherTableViewController ()<UITableViewDelegate, UITableViewDataSource>{
    
    NSMutableArray *cityWeather;
    NSMutableDictionary *iconSet;
    Weather *weather;
    //Geolocation *geoloc;
    //ViewController *view;
    
}

@end

@implementation WeatherTableViewController
@synthesize geolocview;
@synthesize prueba;
- (void)viewDidLoad {
    [super viewDidLoad];
    iconSet=[[NSMutableDictionary alloc]init];
    [self createIconSetCodeDictionary];
    cityWeather=[[NSMutableArray alloc] init];
    [self loadVicinity];
    [self loadWeatherData :[self loadVicinity]];
    
    
    self.title=@"Weather of the nearest cities";
    
    //register Custom Table cell
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WeatherTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WeatherTableViewCell class])];
    
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (NSMutableDictionary *) loadVicinity{
    NSMutableDictionary *cityList=[[NSMutableDictionary alloc]init];
    NSError *error;

    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"GeolocationEntity"];
    NSMutableArray *locations = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSDictionary *lastObj=[locations lastObject];
    NSString *latitudeParam =[lastObj valueForKey:@"latitude"];
    NSString *longitudeParam =[lastObj valueForKey:@"longitude"];
    NSString *radiusParam =[lastObj valueForKey:@"radius"];
    
    NSString *url_string = [NSString stringWithFormat:@"%@%@,%@%@%@%@",@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=", latitudeParam, longitudeParam,@"&radius=",radiusParam,@"&types=city_hall&key=AIzaSyAvCspNjtqsE7lg7KEbIUxtlDFAY-8QwSY"];
    NSLog(@"url_string : %@", url_string);
    
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSDictionary *jsonList=(NSDictionary*) [json valueForKey:@"results"];
    NSString *vicinity;
    
    for (NSDictionary *dic in jsonList){
        vicinity=(NSString*) [dic valueForKey:@"vicinity"];
        NSArray *city =[[NSArray alloc] init];
        city = [vicinity componentsSeparatedByString:@","];
        
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
        
        NSString *responseCode  = [NSString stringWithFormat:@"%@", json[@"cod"]];
        NSString *responseOK=@"200";
        
        if ([responseCode isEqualToString:responseOK]) {
            [self readCitiesList:json];
        }
        
        
        
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
    
    NSDictionary *weatherData =jsonList[@"weather"];
    NSString *description;
    NSString *cod;
    for (NSDictionary *mainDic in weatherData){
        description = (NSString*) [mainDic valueForKey:@"description"];
        cod = [NSString stringWithFormat:@"%@", [mainDic valueForKey:@"id"]];
    }
    NSLog(@"description es : %@", description);
    [weather setDescription:description];
    [weather setCod:cod];
    
    NSString *urlimg=[self getImageFromCode:cod];
    [weather setUrlIcon:urlimg];
    
    //NSLog(@"weather es : %@", weather);
    [cityWeather addObject:weather];
    
}
-(NSString *) getImageFromCode:(NSString * )imgCode {
    
    NSString *valueImg=[iconSet objectForKey:imgCode ];
    
    NSLog(@"valueImg %@",valueImg );
    NSString *combinedURL = [NSString stringWithFormat:@"%@%@%@",@"icons/", valueImg, @"d.png"];
    
    NSLog(@"combinedURL %@",combinedURL );

    
    return combinedURL;
}
- (void) createIconSetCodeDictionary {
    
    //Group 2xx: Thunderstorm
    [iconSet setObject:@"11" forKey:@"200"];
    [iconSet setObject:@"11" forKey:@"201"];
    [iconSet setObject:@"11" forKey:@"202"];
    [iconSet setObject:@"11" forKey:@"210"];
    [iconSet setObject:@"11" forKey:@"211"];
    [iconSet setObject:@"11" forKey:@"212"];
    [iconSet setObject:@"11" forKey:@"221"];
    [iconSet setObject:@"11" forKey:@"230"];
    [iconSet setObject:@"11" forKey:@"231"];
    [iconSet setObject:@"11" forKey:@"232"];
    
    //Group 3xx: Drizzle
    [iconSet setObject:@"09" forKey:@"300"];
    [iconSet setObject:@"09" forKey:@"301"];
    [iconSet setObject:@"09" forKey:@"302"];
    [iconSet setObject:@"09" forKey:@"310"];
    [iconSet setObject:@"09" forKey:@"311"];
    [iconSet setObject:@"09" forKey:@"312"];
    [iconSet setObject:@"09" forKey:@"313"];
    [iconSet setObject:@"09" forKey:@"314"];
    [iconSet setObject:@"09" forKey:@"321"];
    
    //Group 5xx: Rain
    [iconSet setObject:@"10" forKey:@"500"];
    [iconSet setObject:@"10" forKey:@"501"];
    [iconSet setObject:@"10" forKey:@"502"];
    [iconSet setObject:@"10" forKey:@"503"];
    [iconSet setObject:@"10" forKey:@"504"];
    [iconSet setObject:@"13" forKey:@"511"];
    [iconSet setObject:@"09" forKey:@"520"];
    [iconSet setObject:@"09" forKey:@"521"];
    [iconSet setObject:@"09" forKey:@"522"];
    [iconSet setObject:@"09" forKey:@"531"];
    
    //Group 6xx: Snow
    [iconSet setObject:@"13" forKey:@"600"];
    [iconSet setObject:@"13" forKey:@"601"];
    [iconSet setObject:@"13" forKey:@"602"];
    [iconSet setObject:@"13" forKey:@"611"];
    [iconSet setObject:@"13" forKey:@"612"];
    [iconSet setObject:@"13" forKey:@"615"];
    [iconSet setObject:@"13" forKey:@"616"];
    [iconSet setObject:@"13" forKey:@"620"];
    [iconSet setObject:@"13" forKey:@"621"];
    [iconSet setObject:@"13" forKey:@"622"];
    
    //Group 7xx: Atmosphere
    [iconSet setObject:@"50" forKey:@"701"];
    [iconSet setObject:@"50" forKey:@"711"];
    [iconSet setObject:@"50" forKey:@"721"];
    [iconSet setObject:@"50" forKey:@"731"];
    [iconSet setObject:@"50" forKey:@"741"];
    [iconSet setObject:@"50" forKey:@"751"];
    [iconSet setObject:@"50" forKey:@"761"];
    [iconSet setObject:@"50" forKey:@"762"];
    [iconSet setObject:@"50" forKey:@"771"];
    [iconSet setObject:@"50" forKey:@"781"];
    
    //Group 800: Clear
    [iconSet setObject:@"01" forKey:@"800"];
    
    //Group 80x: Clouds
    [iconSet setObject:@"02" forKey:@"801"];
    [iconSet setObject:@"03" forKey:@"802"];
    [iconSet setObject:@"04" forKey:@"803"];
    [iconSet setObject:@"04" forKey:@"804"];
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
    cell.imageView.image= [UIImage imageNamed:dataWeather.urlIcon];
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
