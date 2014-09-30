//
//  ForecastService.m
//  Barometer
//
//  Created by Fabian Canas on 9/25/14.
//  Copyright (c) 2014 Fabian Canas. All rights reserved.
//

#import "ForecastService.h"


@import CoreLocation;

@interface ForecastService () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) NSURLSession *session;
@end


@implementation ForecastService

#pragma mark - Weather

- (instancetype)init
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    return self;
}

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
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [self.consumer forcastReturnedBarometerReading:barometerReading];
                                                     });
                                                 }];
    [task resume];
}

#pragma mark - Location Delegate Methods

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
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

- (void)     locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self startUpdatingWeather];
    }
}

@end
