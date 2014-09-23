//
//  BRBarometerReading.h
//  Barometer
//
//  Created by Ryan Coughlin on 9/22/14.
//  Copyright (c) 2014 Ryan Coughlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRBarometerReading : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *pressure;

- (instancetype)initWithPressure:(NSNumber *)airPressureNumber currentDate:(NSDate *)date;

@end
