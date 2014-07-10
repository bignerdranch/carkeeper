//
//  BNRTableViewFetchedResultsControllerDelegate.h
//  CarKeeper
//
//  Created by Brian Hardy on 7/9/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRTableViewFetchedResultsControllerDelegate : NSObject <NSFetchedResultsControllerDelegate>

- (instancetype)initWithTableView:(UITableView *)tableView;

@end
