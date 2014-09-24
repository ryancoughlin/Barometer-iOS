//
//  PressureHistory.m
//  Barometer
//
//  Created by Fabian Canas on 9/23/14.
//  Copyright (c) 2014 Ryan Coughlin. All rights reserved.
//

#import "PressureHistory.h"
#import <Realm/Realm.h>
#import "BRBarometerReading.h"

@interface PressureHistory ()
@property (nonatomic, strong) RLMRealm *realm;
@property (nonatomic, strong) BRBarometerReading *latestReading;

@property (nonatomic, readwrite, strong) BRBarometerReading *low;
@property (nonatomic, readwrite, strong) BRBarometerReading *high;
@end

@implementation PressureHistory

- (instancetype)init
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _realm = [RLMRealm defaultRealm];
    
    return self;
}

- (void)addReading:(BRBarometerReading *)reading
{
    double pressureChange = fabs(reading.pressure - self.latestReading.pressure);
    if (pressureChange < 0.01) {
        return;
    }
    
    [self.realm transactionWithBlock:^{
        [self.realm addObject:reading];
    }];
}

- (void)updateRecents
{
    static NSTimeInterval oneDay = 60 * 60 * 24;
    RLMArray *recentReadings = [BRBarometerReading objectsWhere:@"date > %@", [NSDate dateWithTimeIntervalSinceNow:-oneDay]];
    recentReadings = [recentReadings arraySortedByProperty:NSStringFromSelector(@selector(pressure))
                                                 ascending:YES];
    
    self.low = recentReadings.firstObject;
    self.high = recentReadings.lastObject;
}

@end
