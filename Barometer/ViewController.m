//
//  ViewController.m
//  Barometer
//
//  Created by Ryan Coughlin on 9/22/14.
//  Copyright (c) 2014 Ryan Coughlin. All rights reserved.
//

@import CoreMotion;

#import "BRScaleLines.h"
#import "BRBarometerReading.h"
#import "ViewController.h"
#import "PressureHistory.h"

@interface ViewController ()

@property CMAltimeter *altitude;
@property NSLengthFormatter *lengthFormatter;
@property (nonatomic, strong) PressureHistory *pressureHistory;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pressureHistory = [PressureHistory new];
    
    if ([CMAltimeter isRelativeAltitudeAvailable]) {
        self.altitude = [[CMAltimeter alloc] init];
        [self.altitude startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue]
                                               withHandler:^(CMAltitudeData *altitudeData, NSError *error)
        {
            if (error) {
                NSLog(@"Error: %@", error);
            }
            
            BRBarometerReading *currentReading = [[BRBarometerReading alloc] initWithPressure:[altitudeData.pressure doubleValue]
                                                                                  currentDate:[NSDate date]];
            
            [self.pressureHistory addReading:currentReading];
            
            [UIView animateWithDuration:1 animations:^{
                [self.scaleLinesView setCurrent:currentReading.pressure];
            }];

            self.airPressureLabel.text = [self formatNumberToTwoDecimalPlacesWithNumber:@(currentReading.pressure)];
        }];
    } else {
        NSLog(@"Hardware not supported.");
    }
}

- (NSString *)formatNumberToTwoDecimalPlacesWithNumber:(NSNumber *)number
{
    NSNumberFormatter *formatTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
    [formatTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatTwoDecimalPlaces setMaximumFractionDigits:2];
    [formatTwoDecimalPlaces setRoundingMode: NSNumberFormatterRoundUp];

    return [formatTwoDecimalPlaces stringFromNumber:number];
}

@end
