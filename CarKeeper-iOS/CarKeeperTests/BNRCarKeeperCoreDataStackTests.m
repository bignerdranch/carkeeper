//
//  BNRCarKeeperCoreDataStackTests.m
//  CarKeeper
//
//  Created by Brian Hardy on 6/29/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "BNRCarKeeperCoreDataStack.h"
#import "BNRCar.h"

@interface BNRCarKeeperCoreDataStack ()

+ (NSManagedObjectModel *)managedObjectModel;
- (instancetype)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)psc;

@end

@interface BNRCarKeeperCoreDataStack (Testing)

+ (NSPersistentStoreCoordinator *)newInMemoryPersistenStoreCoordinator;

@end

@implementation BNRCarKeeperCoreDataStack (Testing)

+ (NSPersistentStoreCoordinator *)newInMemoryPersistenStoreCoordinator
{
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSError *error;
    id store = [psc addPersistentStoreWithType:NSInMemoryStoreType
                                 configuration:nil
                                           URL:nil
                                       options:nil
                                         error:&error];
    if (store) {
        return psc;
    } else {
        NSLog(@"Error adding in-memory store: %@", error);
        return nil;
    }
}

@end

@interface BNRCarKeeperCoreDataStackTests : XCTestCase

@property (nonatomic, strong) BNRCarKeeperCoreDataStack *stack;

@end

@implementation BNRCarKeeperCoreDataStackTests

- (void)setUp
{
    [super setUp];
    
    self.stack = [[BNRCarKeeperCoreDataStack alloc] initWithPersistentStoreCoordinator:[BNRCarKeeperCoreDataStack newInMemoryPersistenStoreCoordinator]];
}

- (void)tearDown
{
    self.stack = nil;
    
    [super tearDown];
}

- (void)testCarCreationInBackgroundMOC
{
    NSError *error;
    BOOL success = [self.stack performBlockOnBackgroundContext:^BOOL(NSManagedObjectContext *backgroundMOC) {
        BNRCar *car = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([BNRCar class]) inManagedObjectContext:backgroundMOC];
        car.nickname = @"Big Bertha";
        car.make = @"Ford";
        car.model = @"Darlington";
        car.year = 2014;
        
        return YES;
    } error:&error];
    
    XCTAssertTrue(success);
    XCTAssertNil(error);
    
    // fetch the cars
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([BNRCar class])];
    fetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"year" ascending:YES]];
    
    NSArray *cars = [self.stack.managedObjectContext executeFetchRequest:fetch error:&error];
    XCTAssertEqual(cars.count, 1);
    BNRCar *car = [cars firstObject];
    XCTAssertEqualObjects(car.nickname, @"Big Bertha");
    XCTAssertEqualObjects(car.make, @"Ford");
    XCTAssertEqualObjects(car.model, @"Darlington");
    XCTAssertEqual(car.year, 2014);
}

- (void)testNotSavingInBackgroundMOC
{
    NSError *error;
    BOOL success = [self.stack performBlockOnBackgroundContext:^BOOL(NSManagedObjectContext *backgroundMOC) {
        BNRCar *car = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([BNRCar class]) inManagedObjectContext:backgroundMOC];
        car.nickname = @"Big Bertha";
        car.make = @"Ford";
        car.model = @"Darlington";
        car.year = 2014;
        
        return NO;
    } error:&error];
    
    XCTAssertTrue(success);
    XCTAssertNil(error);
    
    // fetch the cars
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([BNRCar class])];
    fetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"year" ascending:YES]];
    
    NSArray *cars = [self.stack.managedObjectContext executeFetchRequest:fetch error:&error];
    XCTAssertEqual(cars.count, 0);
}
@end
