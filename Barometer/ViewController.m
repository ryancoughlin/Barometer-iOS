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
#import "ForecastService.h"

@interface ViewController () <ForecastConsumer>

@property CMAltimeter *altitude;
@property NSLengthFormatter *lengthFormatter;
@property (nonatomic, strong) CMAltimeter *altimeter;
@property (nonatomic, strong) BRBarometerReading *currentReading;
@property (nonatomic, strong) PressureHistory *pressureHistory;
@property (nonatomic, strong) CMAltitudeData *altitudeData;
@property (strong, nonatomic) NSTimer *updateTimer;
@property (strong, nonatomic) ForecastService *forecastService;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pressureHistory = [PressureHistory new];
    
    if ([CMAltimeter isRelativeAltitudeAvailable]) {
        [self startUpdatingAltimeter];
        self.pressureSourceLabel.text = @"Air pressure from device";
    } else {
        self.forecastService = [ForecastService new];
        self.forecastService.consumer = self;
        [self.forecastService startUpdatingWeather];
        self.pressureSourceLabel.text = @"Air pressure from forecast.io";
    }
}

- (void)startUpdatingAltimeter
{
    self.updateTimer = [NSTimer timerWithTimeInterval:0.4
                                               target:self
                                             selector:@selector(updateUI:)
                                             userInfo:nil
                                              repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
    self.altimeter = [[CMAltimeter alloc] init];
    [self.altimeter startRelativeAltitudeUpdatesToQueue:[NSOperationQueue new]
                                            withHandler:^(CMAltitudeData *altitudeData, NSError *error) {
                                                BRBarometerReading *currentReading = [[BRBarometerReading alloc] initWithPressure:[altitudeData.pressure doubleValue]
                                                                                                                      currentDate:[NSDate date]];
                                                self.currentReading = currentReading;
                                            }];
}

- (void)forcastReturnedBarometerReading:(BRBarometerReading *)reading
{
    self.currentReading = reading;
    [self updateUI:nil];
}

// Must be called on main thread
- (void)updateUI:(NSTimer *)timer
{
    [self.pressureHistory addReading:self.currentReading];
    
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.75
          initialSpringVelocity:0
                        options:kNilOptions
                     animations:^{
                         [self.scaleLinesView setCurrent:[self.currentReading pressureInMMHg]];
                         [self.scaleLinesView setMinimum:[[self.pressureHistory low] pressureInMMHg]];
                         [self.scaleLinesView setMaximum:[[self.pressureHistory high] pressureInMMHg]];
                     }
                     completion:nil];
    
    self.airPressureLabel.text = [self formatNumberToTwoDecimalPlacesWithNumber:@([self.currentReading pressureInMMHg])];
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
