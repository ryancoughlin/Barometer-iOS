//
//  ViewController.h
//  Barometer
//
//  Created by Ryan Coughlin on 9/22/14.
//  Copyright (c) 2014 Ryan Coughlin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *airPressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *airPressureUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *relativeAltitudeLabel;

@end

