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

#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>

@property CMAltimeter *altitude;
@property NSLengthFormatter *lengthFormatter;
@property (nonatomic, strong) CMAltimeter *altimeter;
@property (nonatomic, strong) BRBarometerReading *currentReading;
@property (nonatomic, strong) PressureHistory *pressureHistory;
@property (nonatomic, strong) CMAltitudeData *altitudeData;
@property (strong, nonatomic) NSTimer *updateTimer;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) NSURLSession *session;
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
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self startUpdatingWeather];
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

// Must be called on main thread
- (void)updateUI:(NSTimer *)timer
{
    [self.pressureHistory addReading:self.currentReading];
    
    [UIView animateWithDuration:1 animations:^{
        [self.scaleLinesView setCurrent:[self.currentReading pressureInMMHg]];
    }];
    
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

#pragma mark - Weather

- (NSURL *)currentLocationURL
{
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"https";
    components.host = @"api.forecast.io";
    
    NSString *p = [NSString stringWithFormat:@"/forecast/%@/%.4f,%.4f",
                   FORECAST_IO_KEY,
                   self.lastLocation.coordinate.latitude,
                   self.lastLocation.coordinate.longitude];
    components.path = p;
    return [components URL];
}

- (void)startUpdatingWeather
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationManager.distanceFilter = 2000;
    [self.locationManager startUpdatingLocation];
}

- (void)updateWeather
{
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[self currentLocationURL]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:10];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     if (error) {
                                                         //err
                                                         return;
                                                     }
                                                     
                                                     NSError *localError = nil;
                                                     NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                                                          options:kNilOptions
                                                                                                            error:&error];
                                                     if (localError) {
                                                         // err
                                                         return;
                                                     }
                                                     
                                                     dict = dict[@"currently"];
                                                     
                                                     double pressure = [(NSString *)dict[@"pressure"] doubleValue]/10.; // in kPa
                                                     BRBarometerReading *barometerReading = [[BRBarometerReading alloc] initWithPressure:pressure
                                                                                                                             currentDate:[NSDate date]];
                                                     self.currentReading = barometerReading;
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [self updateUI:nil];
                                                     });
                                                 }];
    [task resume];
}

#pragma mark - Location Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSTimeInterval timeInterval = [location.timestamp timeIntervalSinceDate:self.lastLocation.timestamp];
    
    double hoursSinceLastUpdate = (timeInterval/60.)/60.;
    
    // Rate limit forecast.io API
    if (hoursSinceLastUpdate > 1 || self.lastLocation == nil) {
        self.lastLocation = location;
        [self updateWeather];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self startUpdatingWeather];
    }
}

@end
