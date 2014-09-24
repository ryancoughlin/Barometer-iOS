//
//  PressureHistory.h
//  Barometer
//
//  Created by Fabian Canas on 9/23/14.
//  Copyright (c) 2014 Ryan Coughlin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BRBarometerReading;

@interface PressureHistory : NSObject
@property (nonatomic, readonly) BRBarometerReading *low;
@property (nonatomic, readonly) BRBarometerReading *high;

- (void)addReading:(BRBarometerReading *)reading;

@end
