//
//  BRBarometerReading.h
//  Barometer
//
//  Created by Ryan Coughlin on 9/22/14.
//  Copyright (c) 2014 Ryan Coughlin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface BRBarometerReading : RLMObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic) double pressure;

- (instancetype)initWithPressure:(double)airPressureNumber currentDate:(NSDate *)date;

@end
