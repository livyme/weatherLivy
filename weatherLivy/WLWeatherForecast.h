//
//  WLWeatherForecast.h
//  weatherLivy
//
//  Created by Livy on 3/2/13.
//  Copyright (c) 2013 Livy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WLWeatherForecast : NSObject <CLLocationManagerDelegate>

- (NSDictionary *) getWeatherData: (NSDictionary *) placemarkAddress iSCurrent:(BOOL)currentOrForecast;
@end
