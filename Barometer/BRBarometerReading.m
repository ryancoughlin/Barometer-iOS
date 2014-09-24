//
//  BRBarometerReading.m
//  Barometer
//
//  Created by Ryan Coughlin on 9/22/14.
//  Copyright (c) 2014 Ryan Coughlin. All rights reserved.
//

#import "BRBarometerReading.h"

static const double kpaToInHG = 0.296133971008484;

@implementation BRBarometerReading

- (instancetype)initWithPressure:(double)airPressureNumber currentDate:(NSDate *)date
{
    self = [super init];

    if(self == nil) {
        return nil;
    }
    
    _date = date;
    _pressure = airPressureNumber;
    
    return self;
}

- (double)pressureInMMHg
{
    return self.pressure * kpaToInHG;
}

- (double)pressureInKPa
{
    return self.pressure;
}

@end
