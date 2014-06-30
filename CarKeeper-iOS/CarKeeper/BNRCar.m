//
//  BNRCar.m
//  CarKeeper
//
//  Created by Brian Hardy on 6/21/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRCar.h"


@implementation BNRCar

@dynamic nickname;
@dynamic make;
@dynamic model;
@dynamic rgbColor;
@dynamic year;

+ (BNRCar *)insertCarInManagedObjectContext:(NSManagedObjectContext *)moc
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([BNRCar class]) inManagedObjectContext:moc];
}

- (NSString *)userDescription
{
    NSMutableString *carText = [[NSMutableString alloc] init];
    [carText appendFormat:@"%d %@ %@", self.year, self.make, self.model];
    if (self.nickname.length) {
        [carText appendFormat:@", \"%@\"", self.nickname];
    }
    return [carText copy];
}

@end
