//
//  BNRCarsResponseHandler.m
//  CarKeeper
//
//  Created by Brian Hardy on 6/29/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRCarsResponseHandler.h"
#import "BNRCar.h"
#import "BNRCarKeeperErrors.h"

@interface BNRCarsResponseHandler ()

@property BNRCarKeeperCoreDataStack *stack;

@end

@implementation BNRCarsResponseHandler

- (instancetype)initWithCoreDataStack:(BNRCarKeeperCoreDataStack *)stack
{
    self = [super init];
    if (self) {
        self.stack = stack;
    }
    return self;
}

- (BOOL)handleHTTPResponse:(NSHTTPURLResponse *)response withData:(NSData *)data error:(NSError **)error
{
    if ([response statusCode] == 200) {
        NSError *jsonError;
        NSArray *carDicts = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (carDicts) {
            // parse the dictionaries into BNRCar objects, inserting them into a MOC
            NSError *coreDataError;
            BOOL success = [self.stack performBlockOnBackgroundContext:^BOOL(NSManagedObjectContext *backgroundMOC) {
                for (NSDictionary *carDict in carDicts) {
                    [BNRCar insertCarInManagedObjectContext:backgroundMOC withDictionary:carDict];
                }
                
                return YES;
            } error:&coreDataError];
            
            if (success) {
                *error = nil;
                return YES;
            } else {
                *error = coreDataError;
                return NO;
            }
            
        } else {
            *error = jsonError;
            return NO;
        }
    } else {
        NSLog(@"Bad response when retrieving cars: %@", response);
        *error = [NSError errorWithDomain:BNRCarKeeperErrorDomain
                                     code:BNRCarKeeperErrorCodeBadResponse
                                 userInfo:@{ @"Response" : response}];
        return NO;
    }
}

@end
