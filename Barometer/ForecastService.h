//
//  ForecastService.h
//  Barometer
//
//  Created by Fabian Canas on 9/25/14.
//  Copyright (c) 2014 Fabian Canas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRBarometerReading.h"


@protocol ForecastConsumer <NSObject>

- (void)forcastReturnedBarometerReading:(BRBarometerReading *)reading;

@end


@interface ForecastService : NSObject
- (void)startUpdatingWeather;
@property (nonatomic, weak) id<ForecastConsumer> consumer;
@end
