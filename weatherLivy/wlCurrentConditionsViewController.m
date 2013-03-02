//
//  wlCurrentConditionsViewController.m
//  weatherLivy
//
//  Created by Livy on 3/2/13.
//  Copyright (c) 2013 Livy. All rights reserved.
//

#import "wlCurrentConditionsViewController.h"

@interface wlCurrentConditionsViewController ()
@property (nonatomic, strong) CLLocationManager *locManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (nonatomic, strong) NSString *statusMessage;

@property (nonatomic, readwrite) NSDictionary *weatherInfo;


@end

@implementation wlCurrentConditionsViewController
@synthesize weatherForecast;
@synthesize statusMessage;
@synthesize locManager,geocoder;
@synthesize weatherInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self startLocationManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) startLocationManager {
    locManager = [[CLLocationManager alloc] init];
    // Global location services should be enabled.
    if (CLLocationManager.locationServicesEnabled) {
        statusMessage = @"Finding your current location...";
        locManager.delegate = self;
        // Don't need too much accuracy. +/- 100m would be enough for this test.
        locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [locManager startUpdatingLocation];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(displayWeatherData:)
                                                     name:@"AddressReady" object:nil];
    } else {
        statusMessage = @"Location Service is disabled.";
        NSLog(@"%@",statusMessage);
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //location update should be stopped to save power
    [locManager stopUpdatingLocation];
    
    geocoder = [[CLGeocoder alloc] init];
    
    [self.geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
        // Find the current placemark
        CLPlacemark *placemark = [placemarks lastObject];
        // Get city and state name
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddressReady" object:nil userInfo: placemark.addressDictionary];
    }];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"<<>>>>>>");
    
    [locManager stopUpdatingLocation];
    switch (error.code) {
            
            // If the application specific location setting is disabled
        case kCLErrorDenied:
            statusMessage = @"Location service denied.";
            break;
            
            // Are you from Mars?
        case kCLErrorLocationUnknown:
            statusMessage = @"Location data unavailable";
            break;
        default:
            statusMessage = @"Unknown error";
            break;
    }
    NSLog(@"%@",statusMessage);
}

- (void) displayWeatherData: (NSNotification *) notification {
    weatherForecast = [[WLWeatherForecast alloc] init];
    weatherInfo = [weatherForecast getWeatherData:notification.userInfo iSCurrent:true];
    
}

@end
