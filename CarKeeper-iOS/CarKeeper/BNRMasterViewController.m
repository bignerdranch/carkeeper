//
//  BNRMasterViewController.m
//  CarKeeper
//
//  Created by Brian Hardy on 6/21/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRMasterViewController.h"

#import "BNRDetailViewController.h"

#import "BNRCar.h"
#import "BNRCarListResultsController.h"
#import "BNRTableViewFetchedResultsControllerDelegate.h"

@interface BNRMasterViewController ()

@property (nonatomic) BOOL isDataLoaded;

@property (nonatomic, strong) NSFetchedResultsController *carsFetchedResultsController;
@property (nonatomic, strong) BNRTableViewFetchedResultsControllerDelegate *tableViewFRCDelegate;
@property (nonatomic, strong) BNRCarListResultsController *carListResultsController;

@end

@implementation BNRMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (BNRDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // set up the fetched results controller and the car list results controller
    NSError *error;
    self.carsFetchedResultsController = [self.store fetchCars:&error];
    if (self.carsFetchedResultsController) {
        self.tableViewFRCDelegate = [[BNRTableViewFetchedResultsControllerDelegate alloc] initWithTableView:self.tableView];
        self.carsFetchedResultsController.delegate = self.tableViewFRCDelegate;
        self.carListResultsController = [[BNRCarListResultsController alloc] initWithFetchedResultsController:self.carsFetchedResultsController];
        self.tableView.dataSource = self.carListResultsController;
    } else {
        NSLog(@"Error fetching cars: %@", error);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.isDataLoaded) {
        [self.store loadCarsWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                self.isDataLoaded = YES;
            } else {
                NSLog(@"Error loading cars: %@", error);
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    NSError *error;
    BNRCar *newCar = [self.store insertDefaultNewCar:&error];
    if (!newCar) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        BNRCar *car = [self.carListResultsController carAtIndexPath:indexPath];
        self.detailViewController.detailItem = car;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BNRCar *car = [self.carListResultsController carAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:car];
    }
}


@end
