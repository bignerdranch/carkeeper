//
//  BNRCarPresenter.h
//  CarKeeper
//
//  Created by Brian Hardy on 12/3/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNRCar.h"

@interface BNRCarPresenter : NSObject

- (instancetype)initWithCar:(BNRCar *)car;

@property (nonatomic, readonly) UIColor *color;

@end
