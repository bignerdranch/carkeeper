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
             // parse the dictionaries into BNRCar objects
             NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
             childContext.parentContext = self.coreDataStack.managedObjectContext;
             
             // listen for saves to save the main context
             id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                                             object:childContext
                                                                              queue:[NSOperationQueue mainQueue]
                                                                         usingBlock:^(NSNotification *note) {
                                                                             NSError *saveError;
                                                                             BOOL success = [self.coreDataStack.managedObjectContext save:&saveError];
                                                                             if (!success) {
                                                                                 NSLog(@"Error saving main context: %@", saveError);
                                                                             }
                                                                         }];
             
             [childContext performBlockAndWait:^{
                 for (NSDictionary *carDict in carDicts) {
                     BNRCar *car = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([BNRCar class]) inManagedObjectContext:childContext];
                     car.make = carDict[@"make"];
                     car.model = carDict[@"model"];
                     car.year = [carDict[@"year"] integerValue];
                     car.nickname = carDict[@"nickname"];
                     car.rgbColor = [carDict[@"rgb_color"] integerValue];
                 }
                 
                 NSError *saveError;
                 BOOL success = [childContext save:&saveError];
                 if (!success) {
                     [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                         completionBlock(NO, saveError);
                     }];
                 }
             }];
             
             [[NSNotificationCenter defaultCenter] removeObserver:observer];

             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 completionBlock(YES, nil);
             }];
             
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
