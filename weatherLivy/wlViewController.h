//
//  wlViewController.h
//  weatherLivy
//
//  Created by Livy on 2/26/13.
//  Copyright (c) 2013 Livy. All rights reserved.
//

#import <UIKit/UIKit.h>

//The protocols are added in order for the table view to display correctly.
@interface wlViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentConditionLable;
@property (weak, nonatomic) IBOutlet UIImageView *weatherImage;
@property (weak, nonatomic) IBOutlet UIImageView *livyIconImage;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLable;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, readwrite) NSArray *forecastDaysArray;

@end
