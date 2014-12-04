//
//  BNRCarPresenter.m
//  CarKeeper
//
//  Created by Brian Hardy on 12/3/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRCarPresenter.h"

@interface BNRCarPresenter ()

@property (nonatomic, strong) BNRCar *car;

@end

@implementation BNRCarPresenter

- (instancetype)initWithCar:(BNRCar *)car {
    self = [super init];
    if (self) {
        self.car = car;
    }
    return self;
}

- (UIColor *)color {
    int64_t rgbColor = self.car.rgbColor;
    int blue = rgbColor & 0xFF;
    int green = (rgbColor >> 8) & 0xFF;
    int red = (rgbColor >> 16) & 0xFF;
    UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    return color;
}

- (NSString *)description {
    NSMutableString *carText = [[NSMutableString alloc] init];
    [carText appendFormat:@"%d %@ %@", self.car.year, self.car.make, self.car.model];
    if (self.car.nickname.length) {
        [carText appendFormat:@", \"%@\"", self.car.nickname];
    }
    return [carText copy];
}

@end
