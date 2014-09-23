//
//  BRScaleLines.m
//  Barometer
//
//  Created by Ryan Coughlin on 9/23/14.
//  Copyright (c) 2014 Ryan Coughlin. All rights reserved.
//

@import CoreGraphics;
#import "BRScaleLines.h"

@interface BRScaleLines ()

@property (nonatomic) float minimumRange;
@property (nonatomic) float maximumRange;
@property (nonatomic) float granularity;

@property (nonatomic, strong) UIView *maxMarker;
@property (nonatomic, strong) UIView *minMarker;
@property (nonatomic, strong) UIView *currentMarker;

@end

@implementation BRScaleLines

- (CGFloat)height
{
    return self.bounds.size.height;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        _minimumRange = 25;
        _maximumRange = 35;
        _granularity = 0.1;
        
        self.maxMarker = [self markerWithColor:[UIColor greenColor]];
        [self addSubview:self.maxMarker];
        self.minMarker = [self markerWithColor:[UIColor redColor]];
        [self addSubview:self.minMarker];
        self.currentMarker = [self markerWithColor:[UIColor cyanColor]];
        [self addSubview:self.currentMarker];
    }

    return self;
}

- (UIView *)markerWithColor:(UIColor *)color
{
    UIView *marker = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 12, 12)];
    marker.backgroundColor = color;
    marker.layer.cornerRadius = 6;

    return marker;
}

- (CGFloat)yPositionForValue:(double)value
{
    return (value - self.minimumRange) * ([self height]/(self.maximumRange - self.minimumRange));
}

- (void)setMinimum:(float)minimum
{
    self.minMarker.center = CGPointMake(20, [self yPositionForValue:minimum]);
}

- (void)setMaximum:(float)minimum
{
    self.maxMarker.center = CGPointMake(20, [self yPositionForValue:minimum]);
}

- (void)setCurrent:(float)minimum
{
    self.currentMarker.center = CGPointMake(20, [self yPositionForValue:minimum]);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);

    int linesNum = (self.maximumRange - self.minimumRange)/self.granularity;
    int spacing = self.height/linesNum;


    for (int i = spacing; i <= spacing*linesNum; i += spacing) {

        CGContextBeginPath(context);

        if ( i % 10 == 0 ) {
            CGContextMoveToPoint(context, 0, i);
            CGContextAddLineToPoint(context, 18, i);
        } else {
            CGContextMoveToPoint(context, 0, i);
            CGContextAddLineToPoint(context, 6, i);
        }

        CGContextStrokePath(context);
    }
}

@end
