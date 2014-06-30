//
//  BNRCarKeeperStore.m
//  CarKeeper
//
//  Created by Brian Hardy on 6/24/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRCarKeeperStore.h"
#import "BNRCar.h"

static NSString * const BNRCarKeeperErrorDomain = @"BNRCarKeeperErrorDomain";

typedef enum : NSUInteger {
    BNRCarKeeperErrorCodeBadResponse,
} BNRCarKeeperErrorCode;

@interface BNRCarKeeperStore ()

@property (nonatomic, strong) BNRCarKeeperCoreDataStack *coreDataStack;

@end

@implementation BNRCarKeeperStore

- (instancetype)initWithCoreDataStack:(BNRCarKeeperCoreDataStack *)stack
{
    self = [super init];
    if (self) {
        self.coreDataStack = stack;
    }
    return self;
}

- (NSFetchedResultsController *)fetchCars:(NSError **)error
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BNRCar" inManagedObjectContext:self.coreDataStack.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.coreDataStack.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    
	[aFetchedResultsController performFetch:error];
    
    return aFetchedResultsController;
}

- (void)loadCarsWithCompletion:(BNRCarKeeperStoreCarsCompletionBlock)completionBlock
{
    // load the data
    NSURL * carsURL = [NSURL URLWithString:@"http://localhost:3000/cars.json"];
    [[[NSURLSession sharedSession] dataTaskWithURL:carsURL
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
     NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
     if (urlResponse && [urlResponse statusCode] == 200) {
         NSError *jsonError;
         NSArray *carDicts = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
         if (carDicts) {
             // parse the dictionaries into BNRCar objects, inserting them into a MOC
             NSError *coreDataError;
             BOOL success = [self.coreDataStack performBlockOnBackgroundContext:^BOOL(NSManagedObjectContext *backgroundMOC) {
                 for (NSDictionary *carDict in carDicts) {
                     [BNRCar insertCarInManagedObjectContext:backgroundMOC withDictionary:carDict];
                 }
                 
                 return YES;
             } error:&coreDataError];
             
             if (success) {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     completionBlock(YES, nil);
                 }];
             } else {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     completionBlock(NO, coreDataError);
                 }];
             }
             
         } else {
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 completionBlock(NO, jsonError);
             }];
         }
     } else {
         if (urlResponse) {
             NSLog(@"Bad response when retrieving cars: %@", urlResponse);
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 completionBlock(NO, [NSError errorWithDomain:BNRCarKeeperErrorDomain
                                                         code:BNRCarKeeperErrorCodeBadResponse
                                                     userInfo:@{ @"Response" : urlResponse}]);
             }];
         } else {
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 completionBlock(NO, error);
             }];
         }
     }
    }] resume];
}

@end
