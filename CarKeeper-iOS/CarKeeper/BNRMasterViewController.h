//
//  BNRMasterViewController.h
//  CarKeeper
//
//  Created by Brian Hardy on 6/21/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class BNRDetailViewController;

#import "BNRCarKeeperStore.h"

@interface BNRMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) BNRDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) BNRCarKeeperStore *store;

@end
