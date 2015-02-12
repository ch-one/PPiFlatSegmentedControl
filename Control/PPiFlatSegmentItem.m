//
//  PPiFlatSegmentItem.m
//  PPiFlatSegmentedControl-Demo
//
//  Created by Pedro Piñera Buendía on 14/09/14.
//  Copyright (c) 2014 PPinera. All rights reserved.
//

#import "PPiFlatSegmentItem.h"

@implementation PPiFlatSegmentItem

- (id)initWithTitle:(NSString*)title andIcon:(NSObject*)icon
{
    return [self initWithTitle:title andIcon:icon underlineColor:nil];
}

- (id)initWithTitle:(NSString*)title andIcon:(NSObject*)icon underlineColor:(UIColor*)underlineColor
{
    self = [super init];
    if (self) {
        self.title = title;
        self.icon = icon;
        self.underlineColor = underlineColor;
    }
    return self;
}

@end
