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

@interface ViewController ()

@property CMAltimeter *altitude;
@property NSLengthFormatter *lengthFormatter;
@property NSMutableArray *barometerReadings;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _lengthFormatter = [[NSLengthFormatter alloc] init];
    NSLengthFormatterUnit heightFormatterUnit = NSLengthFormatterUnitFoot;
    _lengthFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    _barometerReadings = [[NSMutableArray alloc] init];
    
    if ([CMAltimeter isRelativeAltitudeAvailable]) {
        self.altitude = [[CMAltimeter alloc] init];
        [self.altitude startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue]
                                               withHandler:^(CMAltitudeData *altitudeData, NSError *error)
        {
            if (error) {
                NSLog(@"Error: %@", error);
            }

            NSString *heightUnitString = [_lengthFormatter unitStringFromValue:[altitudeData.relativeAltitude doubleValue] unit:heightFormatterUnit];

            BRBarometerReading *currentReading = [[BRBarometerReading alloc] initWithPressure:[NSNumber numberWithDouble:[altitudeData.pressure doubleValue]] currentDate:[NSDate date]];
            BRBarometerReading *lastReading = [_barometerReadings lastObject];

            NSString *currentPressure = [self formatNumberToTwoDecimalPlacesWithNumber:currentReading.pressure];
            NSString *lastPressure = [self formatNumberToTwoDecimalPlacesWithNumber:lastReading.pressure];

            if (lastPressure == nil) {
                [_barometerReadings addObject:currentReading];
            } else {
                if (![lastPressure isEqualToString:currentPressure]) {
                    [_barometerReadings addObject:currentReading];
                }
            }
            
            [UIView animateWithDuration:1 animations:^{
                [self.scaleLinesView setCurrent:[currentReading.pressure floatValue]];
            }];

            self.relativeAltitudeLabel.text  = heightUnitString;
            self.airPressureLabel.text = [self formatNumberToTwoDecimalPlacesWithNumber:currentReading.pressure];

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
