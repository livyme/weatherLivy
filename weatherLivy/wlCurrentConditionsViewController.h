//
//  wlCurrentConditionsViewController.h
//  weatherLivy
//
//  Created by Livy on 3/2/13.
//  Copyright (c) 2013 Livy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WLWeatherForecast.h"

@interface wlCurrentConditionsViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, readwrite) WLWeatherForecast *weatherForecast;
@end
