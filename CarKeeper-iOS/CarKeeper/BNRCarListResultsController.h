//
//  BNRCarListResultsController.h
//  CarKeeper
//
//  Created by Brian Hardy on 7/8/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNRCar.h"

@interface BNRCarListResultsController : NSObject

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)frc;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (BNRCar *)carAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)deleteCarAtIndexPath:(NSIndexPath *)indexPath error:(NSError **)error;


@end
