//
//  wlViewController.m
//  weatherLivy
//
//  Created by Livy on 2/26/13.
//  Copyright (c) 2013 Livy. All rights reserved.
//

//The following Weather Underground API was registered to Livy.... For testing purposes....
//Livy reserves the rights to invoke the API at any time.
//Please do not abuse this API.
#define weatherCurrentJSONURL [NSURL URLWithString:@"http://api.wunderground.com/api/9e434b98014f05a8/conditions/q/KS/Hays.json"]
#define weatherForecastJSONURL [NSURL URLWithString:@"http://api.wunderground.com/api/9e434b98014f05a8/forecast/q/KS/Hays.json"]
#define livyIconURL [NSURL URLWithString:@"https://dl.dropbox.com/u/7362629/zhuan_shiliangzhuanhua.png"]

#import "wlViewController.h"

@interface wlViewController ()
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentConditionLable;
@property (weak, nonatomic) IBOutlet UIImageView *weatherImage;
@property (weak, nonatomic) IBOutlet UIImageView *livyIconImage;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLable;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, readwrite) NSArray *forecastDaysArray;
@end

@implementation wlViewController
@synthesize locationLabel, lastUpdateTimeLabel, currentConditionLable, weatherImage, temperatureLable, livyIconImage;
@synthesize forecastDaysArray;
@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //For tableView to display correctly
    _tableView.dataSource = self;
    
    //For table view rows to change height with the amount of text.
    _tableView.delegate = self;
    
    //Display Livy's Signature Image
    livyIconImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:livyIconURL]];
}

- (void) viewWillAppear:(BOOL)animated {
    //Get Current Weather Information From Weather Underground website in JSON format
    NSData* weatherData = [NSData dataWithContentsOfURL:weatherCurrentJSONURL];
    
    //Parse JSON data, store it in a NSDictionary
    NSError *error;
    
    NSDictionary *weatherCurrentJSON = [NSJSONSerialization JSONObjectWithData:weatherData options:kNilOptions error:&error];
    
    //Get Location and Current Weather Information
    NSDictionary *currentObservation = [weatherCurrentJSON objectForKey:@"current_observation"];
    NSDictionary *displayLocation = [currentObservation objectForKey:@"display_location"];
    locationLabel.text = [displayLocation objectForKey:@"full"];
    lastUpdateTimeLabel.text = [currentObservation objectForKey:@"observation_time"];
    currentConditionLable.text = [currentObservation objectForKey:@"weather"];
    temperatureLable.text = [currentObservation objectForKey:@"temperature_string"];
    
    //Get current weather icon
    NSString *imageURLString = [NSString stringWithFormat:@"http://icons.wxug.com/i/c/a/%@.gif",[currentObservation objectForKey:@"icon"]];
    weatherImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: imageURLString]]];
    
    //Get forecast Weather Information From Weather Underground website in JSON format, same as above
    NSDictionary *weatherForecastJSON = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:weatherForecastJSONURL] options:kNilOptions error:&error];
    NSDictionary *forecast = [weatherForecastJSON objectForKey:@"forecast"];
    
    //Get future forcasts to be displayed in the tableView.
    forecastDaysArray = [[forecast objectForKey:@"txt_forecast"] objectForKey:@"forecastday"];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [forecastDaysArray count];
}

//Customize the height of table view rows.
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Get the detailed weather information
    NSString *str = [[forecastDaysArray objectAtIndex:indexPath.row]objectForKey:@"fcttext_metric"];
    
    //Calculate the height for weather information
    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:NSLineBreakByWordWrapping];
    
    //Should add extra space for table view cell Title
    return size.height + 40;
}

//Customize table view cells display
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //standard cell, use UITableViewCellStyleSubtitle style
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    }
    
    // Set up the cell...
    
    //Formatting, add line breaking, unlimited number of lines, set font and size.
    
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    
    //Title
    
    cell.textLabel.text = [[forecastDaysArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    //Subtitle
    cell.detailTextLabel.text = [[forecastDaysArray objectAtIndex:indexPath.row]objectForKey:@"fcttext_metric"];
    
    //Weather Icons.  Note that I did not use the icon as specified in the JSON file. Those icons does not work well with non-white backgrounds.
    NSString *imageURLString = [NSString stringWithFormat:@"http://icons.wxug.com/i/c/a/%@.gif",[[forecastDaysArray objectAtIndex:indexPath.row] objectForKey:@"icon"]];
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
    
    return cell;
}


//If current row is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Do nothing.  Just deselect current row.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
