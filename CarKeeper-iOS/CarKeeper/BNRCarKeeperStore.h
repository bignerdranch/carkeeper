//
//  BNRCarKeeperStore.h
//  CarKeeper
//
//  Created by Brian Hardy on 6/24/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BNRCarKeeperCoreDataStack.h"

typedef void(^BNRCarKeeperStoreCarsCompletionBlock)(BOOL success, NSError *error);

@interface BNRCarKeeperStore : NSObject

- (instancetype)initWithCoreDataStack:(BNRCarKeeperCoreDataStack *)stack;

- (NSFetchedResultsController *)fetchCars:(NSError **)error;

- (void)loadCarsWithCompletion:(BNRCarKeeperStoreCarsCompletionBlock)completionBlock;

@end
