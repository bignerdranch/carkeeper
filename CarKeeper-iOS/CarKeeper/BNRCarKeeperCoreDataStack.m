//
//  BNRCarKeeperCoreDataStack.m
//  CarKeeper
//
//  Created by Brian Hardy on 6/24/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRCarKeeperCoreDataStack.h"

@interface BNRCarKeeperCoreDataStack ()

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation BNRCarKeeperCoreDataStack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (instancetype)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)psc
{
    self = [super init];
    if (self) {
        _persistentStoreCoordinator = psc;
    }
    return self;
}

- (BOOL)performBlockOnBackgroundContext:(BOOL (^)(NSManagedObjectContext *backgroundMOC))backgroundBlock
                                  error:(NSError **)error
{
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    childContext.parentContext = self.managedObjectContext;
    
    // listen for saves to save the main context
    __block BOOL didMainMOCSave;
    __block NSError *mainSaveError;
    // this observer will be triggered synchronously on the main queue before the background save call returns
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                                    object:childContext
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification *note) {
                                                                    didMainMOCSave = [self.managedObjectContext save:&mainSaveError];
                                                                }];
    
    __block BOOL shouldBackgroundMOCSave, didBackgroundMOCSave;
    __block NSError *backgroundSaveError;
    [childContext performBlockAndWait:^{
        shouldBackgroundMOCSave = backgroundBlock(childContext);
        
        if (shouldBackgroundMOCSave) {
            didBackgroundMOCSave = [childContext save:&backgroundSaveError];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:observer];

    if (shouldBackgroundMOCSave && !didBackgroundMOCSave) {
        *error = backgroundSaveError;
        return NO;
    } else if (shouldBackgroundMOCSave && !didMainMOCSave) {
        *error = mainSaveError;
        return NO;
    } else {
        return YES;
    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns a managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
+ (NSManagedObjectModel *)managedObjectModel
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CarKeeper" withExtension:@"momd"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSError *error;
    _persistentStoreCoordinator = [[self class] newSQLitePersistentStoreCoordinatorWithError:&error];
    if (!_persistentStoreCoordinator) {
        NSLog(@"Error creating SQLite persistent store: %@", error);
        abort();
    }
    return _persistentStoreCoordinator;
}

+ (NSPersistentStoreCoordinator *)newSQLitePersistentStoreCoordinatorWithError:(NSError **)error;
{
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CarKeeper.sqlite"];
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    BOOL success = [psc addPersistentStoreWithType:NSSQLiteStoreType
                           configuration:nil
                                     URL:storeURL
                                 options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
                                   error:error];
    
    return success ? psc : nil;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
