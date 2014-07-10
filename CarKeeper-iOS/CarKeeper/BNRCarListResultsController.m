//
//  BNRCarListResultsController.m
//  CarKeeper
//
//  Created by Brian Hardy on 7/8/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRCarListResultsController.h"

@interface BNRCarListResultsController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation BNRCarListResultsController

- (instancetype)initWithFetchedResultsController:(NSFetchedResultsController *)frc
{
    self = [super init];
    if (self) {
        self.fetchedResultsController = frc;
    }
    return self;
}

- (NSInteger)numberOfSections
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [self.fetchedResultsController.sections[section] numberOfObjects];
}

- (BNRCar *)carAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (BOOL)deleteCarAtIndexPath:(NSIndexPath *)indexPath error:(NSError **)error
{
    [self.fetchedResultsController.managedObjectContext deleteObject:[self carAtIndexPath:indexPath]];
    return [self.fetchedResultsController.managedObjectContext save:error];
}

@end
