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
    UIRefreshControl *refreshControl;
}

@end

@implementation WeatherTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    
    iconSet=[[NSMutableDictionary alloc]init];
    [self createIconSetCodeDictionary];
    cityWeather=[[NSMutableArray alloc] init];
    [self loadWeatherData :[self loadCities]];
    
    
    self.title=@"Weather of the nearest cities";
    
    //register Custom Table cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WeatherTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WeatherTableViewCell class])];
}
-(void)refreshData
{
    [self loadCities];
    [self.refreshControl endRefreshing];
}


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (NSMutableDictionary *) loadCities{
    NSMutableDictionary *cityList=[[NSMutableDictionary alloc]init];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"GeolocationEntity"];
    
    NSMutableArray *locations = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    NSDictionary *lastObj=[locations lastObject];
    NSString *latitudeParam =[lastObj valueForKey:@"latitude"];
    NSString *longitudeParam =[lastObj valueForKey:@"longitude"];
    NSString *radiusParam =[lastObj valueForKey:@"radius"];
    
    NSLog(@"radius in load Cities : %@", radiusParam);
    
    NSError *error;
    
    NSString *url_string = [NSString stringWithFormat:@"%@%@,%@%@%@%@",@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=",
                            latitudeParam, longitudeParam,@"&radius=",radiusParam,@"&types=city_hall&key=AIzaSyAvCspNjtqsE7lg7KEbIUxtlDFAY-8QwSY"];
    NSLog(@"url_string : %@", url_string);
    
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error){
        NSLog(@"error: %@",error.description);
    }else{
        NSDictionary *jsonList=(NSDictionary*) [json valueForKey:@"results"];
        NSString *vicinity;
        
        for (NSDictionary *dic in jsonList){
            vicinity=(NSString*) [dic valueForKey:@"vicinity"];
            NSArray *city =[[NSArray alloc] init];
            
            city = [vicinity componentsSeparatedByString:@","];
            if ([city count]>1) {
                NSString *trimmedCity = [[city objectAtIndex:1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                [cityList setObject:trimmedCity forKey:trimmedCity];
                NSLog(@"city name is : %@", trimmedCity);
            }
            
            
        }
        
    }
    
    return cityList;
}



- (void) loadWeatherData:(NSMutableDictionary *)citiesList{
    
    for (id key in citiesList){
        weather=[[Weather alloc] init];
        
        NSError *error;
        NSString *name=[citiesList objectForKey:key];
        
        
        
        NSData *dataTransformation = [name dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *nameWithoutSpecialCharacters = [[NSString alloc] initWithData:dataTransformation encoding:NSASCIIStringEncoding];
        NSLog(@"%@", nameWithoutSpecialCharacters);
        
        
        
        [weather setName:name];
        
        NSString *cityForUrlWithoutSpaces=[nameWithoutSpecialCharacters stringByReplacingOccurrencesOfString:@" " withString:@""];
        if(![cityForUrlWithoutSpaces isEqualToString:@""]){
            NSString *url_string = [NSString stringWithFormat: @"http://api.openweathermap.org/data/2.5/weather?q=%@&appid=46ae8cb55eaae08fd148a6a42f02e902", cityForUrlWithoutSpaces];
            NSLog(@" urlstring used : %@", url_string);
            NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"reading data from city : %@", nameWithoutSpecialCharacters);
            
            NSString *responseCode  = [NSString stringWithFormat:@"%@", json[@"cod"]];
            NSString *responseOK=@"200";
            
            if ([responseCode isEqualToString:responseOK]) {
                [self readDataFromCities:json];
            }
        }else{
            NSLog(@"City does nos exist in openWeather");
        }
    }
}
- (void) readDataFromCities:(NSDictionary *)jsonList {
    
    if([jsonList count] > 0){
        NSDictionary *mainList =jsonList[@"main"];
        
        NSString *temp =mainList[@"temp"];
        int tempInt=[self kelvinToCelsius:temp];
        [weather setTemp:tempInt];
        
        NSString *temp_max =mainList[@"temp_max"];
        int tempMaxInt=[self kelvinToCelsius:temp_max];
        [weather setTemp_max:tempMaxInt];
        
        NSString *temp_min =mainList[@"temp_min"];
        int tempMinInt=[self kelvinToCelsius:temp_min];
        [weather setTemp_min:tempMinInt];
        
        NSDictionary *weatherData =jsonList[@"weather"];
        NSString *description;
        NSString *cod;
        
        for (NSDictionary *mainDic in weatherData){
            description = (NSString*) [mainDic valueForKey:@"description"];
            cod = [NSString stringWithFormat:@"%@", [mainDic valueForKey:@"id"]];
        }
        
        [weather setDescription:description];
        [weather setCod:cod];
        
        NSString *urlimg=[self getImageFromCode:cod];
        [weather setUrlIcon:urlimg];
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *newWeatherEntity= [NSEntityDescription insertNewObjectForEntityForName:@"WeatherEntity" inManagedObjectContext:context];
        [newWeatherEntity setValue:[weather name] forKey:@"city"];
        [newWeatherEntity setValue:[weather description]  forKey:@"weatherDescription"];
        [newWeatherEntity setValue:[NSString stringWithFormat:@"%d",[weather temp]]forKey:@"temp"];
        [newWeatherEntity setValue:[NSString stringWithFormat:@"%d",[weather temp_max]]forKey:@"tempMax"];
        [newWeatherEntity setValue:[NSString stringWithFormat:@"%d",[weather temp_min]]forKey:@"tempMin"];
        
        NSError  *saveError=nil;
        
        if (![context save:&saveError]){
            NSLog(@"Save didnt complete successfully. Error: %@", [saveError localizedDescription]);
        }
        
        [cityWeather addObject:weather];
    }else{
        NSLog(@"JSON is empty");
    };
}
-(NSString *) getImageFromCode:(NSString * )imgCode {
    
    NSString *valueImg=[iconSet objectForKey:imgCode ];
    
    NSLog(@"valueImg %@",valueImg );
    NSString *combinedURL = [NSString stringWithFormat:@"%@%@%@",@"icons/", valueImg, @"d.png"];
    
    NSLog(@"combined URL for img %@",combinedURL );
    
    return combinedURL;
}
- (void) createIconSetCodeDictionary {
    
    //http://openweathermap.org/weather-conditions
    
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

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Weather *dataWeather = [cityWeather objectAtIndex:indexPath.row];
    WeatherTableViewCell *cell=[aTableView dequeueReusableCellWithIdentifier:NSStringFromClass([WeatherTableViewCell class]) forIndexPath:indexPath];
    
    cell.labelName.text=dataWeather.name;
    cell.labelDescription.text=[@"Weather: " stringByAppendingString:dataWeather.description];
    cell.labelTemp.text=[@"Temp: " stringByAppendingString:[NSString stringWithFormat:@"%d",dataWeather.temp]];
    cell.labelTempMin.text=[@"min: " stringByAppendingString:[NSString stringWithFormat:@"%d",dataWeather.temp_min]];
    cell.labelTempMax.text=[@"max: " stringByAppendingString:[NSString stringWithFormat:@"%d",dataWeather.temp_max]];
    cell.imageView.image= [UIImage imageNamed:dataWeather.urlIcon];
    cell.userInteractionEnabled = NO;
    cell.imageView.contentMode=UIViewContentModeCenter;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
