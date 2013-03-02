//
//  WLWeatherForecast.m
//  weatherLivy
//
//  Created by Livy on 3/2/13.
//  Copyright (c) 2013 Livy. All rights reserved.
//
#define weatherUndergroundJSONPrefix @"http://api.wunderground.com/api/9e434b98014f05a8/"
#define livyIconURL [NSURL URLWithString:@"https://dl.dropbox.com/u/7362629/zhuanlivy.png"]
#define currentString @"conditions/q/"
#define forecastString @"forecast10day/q/"
#import "WLWeatherForecast.h"

@implementation WLWeatherForecast


#pragma mark get Data

- (NSDictionary *) getWeatherData: (NSDictionary *) placemarkAddress iSCurrent:(BOOL)currentOrForecast{
    NSString *cityName = [placemarkAddress objectForKey:@"City"];
    NSString *stateName = [placemarkAddress objectForKey:@"State"];
    //    NSString *statusMessage;
    NSMutableDictionary *weatherDataDictionary = [[NSMutableDictionary alloc] init];
    NSString *forecastStringInURL;
    if (currentOrForecast) {
        forecastStringInURL = currentString;
    }else {
        forecastStringInURL = forecastString;
    }
    NSString *currentCityWeatherAPIURLString = [[weatherUndergroundJSONPrefix stringByAppendingString:forecastStringInURL] stringByAppendingString:[NSString stringWithFormat:@"%@/%@.json", stateName, cityName]];
    
    NSURL *currentCityWeatherAPIURL = [NSURL URLWithString:currentCityWeatherAPIURLString];
    // For error handling
    NSError *error;
    
    // Get Current Weather Information From Weather Underground website in JSON format
    NSData* weatherData = [NSData dataWithContentsOfURL:currentCityWeatherAPIURL options:0 error:&error];
    // If error, display error in the label. Continue if no error.
    if (error) {
        [weatherDataDictionary setValue:@"Could not load weather data." forKey:@"statusMessage"];
    } else {
        // Parse JSON data, store it in a NSDictionary
        // kNilOptions is just a constant 0
        NSDictionary *weatherJSON = [NSJSONSerialization JSONObjectWithData:weatherData options:kNilOptions error:&error];
        if (error) {
            //            statusMessage = @"Could not load weather data.";
            [weatherDataDictionary setValue:@"Could not load weather data." forKey:@"statusMessage"];
        } else {
            [weatherDataDictionary setObject:weatherJSON forKey:@"weatherData"];            
        }
        
    }
    return weatherDataDictionary;
}

/************
- (NSDictionary *) getCurrentWeatherData: place:(NSDictionary *) placemarkAddress with:(NSString *)currentOrForecast {
    NSString *cityName = [placemarkAddress objectForKey:@"City"];
    NSString *stateName = [placemarkAddress objectForKey:@"State"];
    //    NSString *statusMessage;
    NSMutableDictionary *weatherDataDictionary = [[NSMutableDictionary alloc] init];
    
    // Current City weather API URL
    NSString *currentCityCurrentWeatherAPIURLString = [[weatherUndergroundJSONPrefix stringByAppendingString:@"conditions/q/"] stringByAppendingString:[NSString stringWithFormat:@"%@/%@.json", stateName, cityName]];
    
    // Convert currentCityWeatherAPIURL to URL
    NSURL *currentCityCurrentWeatherAPIURL = [NSURL URLWithString:currentCityCurrentWeatherAPIURLString];
    
    // For error handling
    NSError *error;
    
    // Get Current Weather Information From Weather Underground website in JSON format
    NSData* weatherData = [NSData dataWithContentsOfURL:currentCityCurrentWeatherAPIURL options:0 error:&error];
    
    // If error, display error in the label. Continue if no error.
    if (error) {
        // lastUpdateTimeLabel.text = error.localizedDescription;
        // Second thought... the error description doesn't provide good information
        //        statusMessage = @"Could not load weather data.";
        [weatherDataDictionary setValue:@"Could not load weather data." forKey:@"statusMessage"];
    } else {
        // Parse JSON data, store it in a NSDictionary
        // kNilOptions is just a constant 0
        NSDictionary *weatherCurrentJSON = [NSJSONSerialization JSONObjectWithData:weatherData options:kNilOptions error:&error];
        if (error) {
            //            statusMessage = @"Could not load weather data.";
            [weatherDataDictionary setValue:@"Could not load weather data." forKey:@"statusMessage"];
        } else {
            // Display Location and Current Weather Information
            [weatherDataDictionary setObject:[weatherCurrentJSON objectForKey:@"current_observation"] forKey:@"currentObservation"];
        }
    }
    return weatherDataDictionary;
}

- (NSDictionary *) getForecastWeatherData: (NSDictionary *) placemarkAddress {
    NSString *cityName = [placemarkAddress objectForKey:@"City"];
    NSString *stateName = [placemarkAddress objectForKey:@"State"];
    //    NSString *statusMessage;
    NSMutableDictionary *weatherDataDictionary = [[NSMutableDictionary alloc] init];
    
    // For error handling
    NSError *error;
    
    // Get forecast Weather Information From Weather Underground website in JSON format, same as above
    NSString *currentCityForecastWeatherAPIURLString = [[weatherUndergroundJSONPrefix stringByAppendingString:@"forecast10day/q/"] stringByAppendingString:[NSString stringWithFormat:@"%@/%@.json", stateName, cityName]];
    NSURL *currentCityForecastWeatherAPIURL = [NSURL URLWithString:currentCityForecastWeatherAPIURLString];
    
    NSDictionary *weatherForecastJSON = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:currentCityForecastWeatherAPIURL] options:kNilOptions error:&error];
    if (error) {
        //        statusMessage = @"Could not load weather data.";
        [weatherDataDictionary setValue:@"Could not load weather data." forKey:@"statusMessage"];
    } else {
        NSDictionary *forecast = [weatherForecastJSON objectForKey:@"forecast"];
        
        // Get future forcasts to be displayed in the tableView.
        NSArray *forecastDaysArray = [[forecast objectForKey:@"txt_forecast"] objectForKey:@"forecastday"];
        [weatherDataDictionary setObject:forecastDaysArray forKey:@"forecastDaysArray"];
        
        // Reload table view if there is a refresh request.
    }
    return weatherDataDictionary;
}
**********/
@end
