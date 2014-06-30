//
//  BNRCarsResponseHandler.h
//  CarKeeper
//
//  Created by Brian Hardy on 6/29/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BNRCarKeeperCoreDataStack.h"

@interface BNRCarsResponseHandler : NSObject

- (instancetype)initWithCoreDataStack:(BNRCarKeeperCoreDataStack *)stack;

- (BOOL)handleHTTPResponse:(NSHTTPURLResponse *)response withData:(NSData *)data error:(NSError **)error;

@end
