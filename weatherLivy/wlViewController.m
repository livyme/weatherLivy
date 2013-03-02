//
//  wlViewController.m
//  weatherLivy
//
//  Created by Livy on 2/26/13.
//  Copyright (c) 2013 Livy. All rights reserved.
//


#import "wlViewController.h"
#import "WLWeatherForecast.h"

@interface wlViewController ()
@property (nonatomic, readwrite) WLWeatherForecast *weatherForecast;
@property (nonatomic, readwrite) NSDictionary *weatherInfo;


@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, readwrite) NSArray *forecastDaysArray;

@property (nonatomic, strong) CLLocationManager *locManager;
@property (strong, nonatomic) CLGeocoder *geocoder;

@end

@implementation wlViewController
@synthesize locationLabel;
@synthesize weatherForecast,weatherInfo;
@synthesize forecastDaysArray;
@synthesize tableView = _tableView;
@synthesize locManager,geocoder;

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    // For tableView to display correctly
    _tableView.dataSource = self;
    
    // For table view rows to change height with the amount of text.
    _tableView.delegate = self;
    
     
    // Set all Label text to nil in case of error reading JSON
    _tableView.alpha = 0;
    locationLabel.text = nil;
    
    // Starts to find the current location
    self.locManager = [[CLLocationManager alloc] init] ;
    [self startLocationManager];
}

//- (IBAction)refreshButtonPressed:(id)sender {
//    // If refresh button is pressed, then reloate, and then get weather
//    [self startLocationManager];
//}

#pragma mark Get Location

- (void) startLocationManager {
    // Global location services should be enabled.
    if (CLLocationManager.locationServicesEnabled) {
        locationLabel.text = @"Finding your current location...";
        locManager.delegate = self;
        // Don't need too much accuracy. +/- 100m would be enough for this test.
        locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [locManager startUpdatingLocation];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(displayWeatherData:)
//                                                     name:@"AddressReady" object:nil];
    } else {
        locationLabel.text = @"Location Service is disabled.";
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //location update should be stopped to save power
    [locManager stopUpdatingLocation];
    
    geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
        // Find the current placemark
        CLPlacemark *placemark = [placemarks lastObject];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddressReady" object:nil userInfo: placemark.addressDictionary];
        [self displayWeatherData:placemark.addressDictionary];
    }];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [locManager stopUpdatingLocation];
    switch (error.code) {
            
            // If the application specific location setting is disabled
        case kCLErrorDenied:
            locationLabel.text = @"Location service denied.";
            break;
            
            // Are you from Mars?
        case kCLErrorLocationUnknown:
            locationLabel.text = @"Location data unavailable";
            break;
        default:
            locationLabel.text = @"Unknown error";
            break;
    }
    
    // If error happens, I'd like to hide the page elements.
    _tableView.alpha = 0;
}

#pragma mark get Data
//- (void) displayWeatherData: (NSNotification *) notification {
- (void) displayWeatherData: (NSDictionary *) notification {
    
    weatherForecast = [[WLWeatherForecast alloc] init];
    weatherInfo = [weatherForecast getWeatherData:notification iSCurrent:false];
    forecastDaysArray = [[[[weatherInfo objectForKey:@"weatherData"] objectForKey:@"forecast"] objectForKey:@"txt_forecast"] objectForKey:@"forecastday"];
    [_tableView reloadData];
    _tableView.alpha = 1;
    locationLabel.text = [[notification objectForKey:@"FormattedAddressLines"] objectAtIndex:2];
    
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
