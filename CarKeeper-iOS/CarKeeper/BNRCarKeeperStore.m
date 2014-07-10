//
//  BNRCarKeeperStore.m
//  CarKeeper
//
//  Created by Brian Hardy on 6/24/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRCarKeeperStore.h"
#import "BNRCar.h"
#import "BNRCarsResponseHandler.h"
#import "BNRCarKeeperErrors.h"

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

- (BNRCar *)insertDefaultNewCar:(NSError **)error
{
    BNRCar *car = [BNRCar insertCarInManagedObjectContext:self.coreDataStack.managedObjectContext];
    
    car.nickname = @"Old Faithful";
    car.make = @"Ford";
    car.model = @"F-150";
    car.year = 1994;
    car.rgbColor = 0xffffff;
    
    // Save the context.
    if (![self.coreDataStack.managedObjectContext save:error]) {
        return nil;
    }
    return car;
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
                                     [self handleCarsResponseCompletionWithData:data
                                                                    urlResponse:response
                                                                          error:error
                                                       mainQueueCompletionBlock:completionBlock];
    }] resume];
}

- (void)handleCarsResponseCompletionWithData:(NSData *)data
                                 urlResponse:(NSURLResponse *)response
                                       error:(NSError *)error
                    mainQueueCompletionBlock:(BNRCarKeeperStoreCarsCompletionBlock)completionBlock
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        BNRCarsResponseHandler *handler = [[BNRCarsResponseHandler alloc] initWithCoreDataStack:self.coreDataStack];
        NSError *handlerError;
        BOOL success = [handler handleHTTPResponse:urlResponse withData:data error:&handlerError];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(success, handlerError);
        }];
    } else {
        if (response) {
            NSLog(@"Bad response when retrieving cars: %@", response);
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(NO, [NSError errorWithDomain:BNRCarKeeperErrorDomain
                                                        code:BNRCarKeeperErrorCodeBadResponse
                                                    userInfo:@{ @"Response" : response}]);
            }];
        }
    }
}

@end
