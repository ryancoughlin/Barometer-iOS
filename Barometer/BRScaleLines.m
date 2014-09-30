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

@property (nonatomic, assign) CGFloat minimum;
@property (nonatomic, assign) CGFloat maximum;
@property (nonatomic, assign) CGFloat current;

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

- (instancetype)initWithCoder:(NSCoder *)aDecoder
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
    return [self height] - (value - self.minimumRange) * ([self height]/(self.maximumRange - self.minimumRange));
}

- (void)setMinimum:(CGFloat)minimum
{
    _minimum = minimum;
    self.minMarker.center = CGPointMake(20, [self yPositionForValue:minimum]);
}

- (void)setMaximum:(CGFloat)maximum
{
    _maximum = maximum;
    self.maxMarker.center = CGPointMake(20, [self yPositionForValue:maximum]);
}

- (void)setCurrent:(CGFloat)current
{
    _current = current;
    self.currentMarker.center = CGPointMake(20, [self yPositionForValue:current]);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // Reset marker positions by "resetting" values;
    [self setMaximum:_maximum];
    [self setMinimum:_minimum];
    [self setCurrent:_current];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);

    NSInteger numberOfLines = (self.maximumRange - self.minimumRange)/self.granularity;
    CGFloat spacing = self.height/numberOfLines;
    
    CGContextBeginPath(context);
    
    for (NSInteger line = 0; line <= numberOfLines; line++) {
        NSInteger dashLength = ( line % 10 == 0 ) ? 18. : 6.;
        CGFloat linePosition = line * spacing;
        
        CGContextMoveToPoint(context, 0, linePosition);
        CGContextAddLineToPoint(context, dashLength,linePosition);
    }
    CGContextStrokePath(context);
}

@end
