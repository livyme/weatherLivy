//
//  wlViewController.m
//  weatherLivy
//
//  Created by Livy on 2/26/13.
//  Copyright (c) 2013 Livy. All rights reserved.
//

//  The embeded Weather Underground API was registered to Livy.... For testing purposes....
//  Livy reserves the rights to NULL the API at any time.
//  Please do not abuse this API.
//
#define weatherUndergroundJSONPrefix @"http://api.wunderground.com/api/9e434b98014f05a8/"
#define livyIconURL [NSURL URLWithString:@"https://dl.dropbox.com/u/7362629/zhuanlivy.png"]


#import "wlViewController.h"

@interface wlViewController ()

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentConditionLable;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLable;

@property (weak, nonatomic) IBOutlet UIImageView *weatherImage;
@property (weak, nonatomic) IBOutlet UIImageView *livyIconImage;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

@property (nonatomic, readwrite) NSArray *forecastDaysArray;

@property (nonatomic, readwrite) CLLocationManager *locManager;
@property (strong, nonatomic) CLGeocoder *geocoder;

@property (readwrite, nonatomic) NSString *cityName;
@property (nonatomic, readwrite) NSString *stateName;


@end

@implementation wlViewController
@synthesize locationLabel, lastUpdateTimeLabel, currentConditionLable, weatherImage, temperatureLable, livyIconImage;
@synthesize forecastDaysArray;
@synthesize tableView = _tableView;
@synthesize locManager,geocoder;
@synthesize cityName, stateName;

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    // For tableView to display correctly
    _tableView.dataSource = self;
    
    // For table view rows to change height with the amount of text.
    _tableView.delegate = self;
    
    // Display Livy's Signature Image
    livyIconImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:livyIconURL]];
    
    // Set all Label text to nil in case of error reading JSON
    livyIconImage.alpha = 0;
    _tableView.alpha = 0;
    locationLabel.text = nil;
    lastUpdateTimeLabel.text = nil;
    currentConditionLable.text = nil;
    temperatureLable.text = nil;
    
    [self startLocationManager];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)refreshButtonPressed:(id)sender {
    [self startLocationManager];
}

#pragma mark Get Location

- (void) startLocationManager {
    if (![CLLocationManager locationServicesEnabled]) {
        lastUpdateTimeLabel.text = @"Locations services disabled";
    } else {
        lastUpdateTimeLabel.text = @"Locating your current location";
        self.locManager = [[CLLocationManager alloc] init] ;
        locManager.delegate = self;
        locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [locManager startUpdatingLocation];
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        cityName = [placemark.addressDictionary objectForKey:@"City"];
        stateName = [placemark.addressDictionary objectForKey:@"State"];
        [self getWeatherData];
    }];
    [locManager stopUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@",error.description);
}

#pragma mark get Data

- (void) getWeatherData {
    
    // Current City weather API URL
    
    NSString *currentCityCurrentWeatherAPIURLString = [[weatherUndergroundJSONPrefix stringByAppendingString:@"conditions/q/"] stringByAppendingString:[NSString stringWithFormat:@"%@/%@.json", stateName, cityName]];
    
    // Convert currentCityWeatherAPIURL to URL
    NSURL *currentCityCurrentWeatherAPIURL = [NSURL URLWithString:currentCityCurrentWeatherAPIURLString];
    
    // For error handling
    NSError *error;
    
    // Get Current Weather Information From Weather Underground website in JSON format
    NSData* weatherData = [NSData dataWithContentsOfURL:currentCityCurrentWeatherAPIURL options:0 error:&error];
    
    // If error, display error in the label. Continue if no error.
    if (error) 
        // lastUpdateTimeLabel.text = error.localizedDescription;
        // Second thought... the error description doesn't provide good information
        lastUpdateTimeLabel.text = @"Could not load weather data.";
     else {
        // Parse JSON data, store it in a NSDictionary
        // kNilOptions is just a constant 0
        NSDictionary *weatherCurrentJSON = [NSJSONSerialization JSONObjectWithData:weatherData options:kNilOptions error:&error];
        if (error)
            lastUpdateTimeLabel.text = @"Could not load weather data.";
        else {
            livyIconImage.alpha = 1;
            // Display Location and Current Weather Information
            NSDictionary *currentObservation = [weatherCurrentJSON objectForKey:@"current_observation"];
            NSDictionary *displayLocation = [currentObservation objectForKey:@"display_location"];
            locationLabel.text = [displayLocation objectForKey:@"full"];
            lastUpdateTimeLabel.text = [currentObservation objectForKey:@"observation_time"];
            currentConditionLable.text = [currentObservation objectForKey:@"weather"];
            temperatureLable.text = [currentObservation objectForKey:@"temperature_string"];
            
            // Get current weather icon
            NSString *imageURLString = [NSString stringWithFormat:@"http://icons.wxug.com/i/c/a/%@.gif",[currentObservation objectForKey:@"icon"]];
            weatherImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: imageURLString]]];
            
            // Get forecast Weather Information From Weather Underground website in JSON format, same as above
            NSString *currentCityForecastWeatherAPIURLString = [[weatherUndergroundJSONPrefix stringByAppendingString:@"forecast/q/"] stringByAppendingString:[NSString stringWithFormat:@"%@/%@.json", stateName, cityName]];
            NSURL *currentCityForecastWeatherAPIURL = [NSURL URLWithString:currentCityForecastWeatherAPIURLString];
            
            NSDictionary *weatherForecastJSON = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:currentCityForecastWeatherAPIURL] options:kNilOptions error:&error];
            if (error)
                lastUpdateTimeLabel.text = @"Could not load weather data.";
            else {
                _tableView.alpha = 1;
                NSDictionary *forecast = [weatherForecastJSON objectForKey:@"forecast"];
                
                // Get future forcasts to be displayed in the tableView.
                forecastDaysArray = [[forecast objectForKey:@"txt_forecast"] objectForKey:@"forecastday"];
                
                // Reload table view if there is a refresh request.
                [self.tableView reloadData];
            }
        }
    }
}

#pragma mark Table View
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [forecastDaysArray count];
}

// Customize the height of table view rows.
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the detailed weather information
    NSString *str = [[forecastDaysArray objectAtIndex:indexPath.row]objectForKey:@"fcttext_metric"];
    
    // Calculate the height for weather information
    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13] constrainedToSize:CGSizeMake(240, 999) lineBreakMode:NSLineBreakByWordWrapping];
    
    // Should add extra space for table view cell Title
    return size.height + 35;
}

// Customize table view cells display
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Standard cell, use UITableViewCellStyleSubtitle style
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    }
    
    // Set up the cell...
    
    // Formatting, add line breaking, unlimited number of lines, set font and size.
    
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    
    // Title
    cell.textLabel.text = [[forecastDaysArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    // Subtitle
    cell.detailTextLabel.text = [[forecastDaysArray objectAtIndex:indexPath.row]objectForKey:@"fcttext_metric"];
    
    // Weather Icons.  Note that I did not use the icon as specified in the JSON file. Those icons does not work well with non-white backgrounds.
    NSString *imageURLString = [NSString stringWithFormat:@"http://icons.wxug.com/i/c/a/%@.gif",[[forecastDaysArray objectAtIndex:indexPath.row] objectForKey:@"icon"]];
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
    
    return cell;
}


// If current row is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Do nothing.  Just deselect current row.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
