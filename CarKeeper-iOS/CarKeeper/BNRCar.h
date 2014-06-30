//
//  BNRCar.h
//  CarKeeper
//
//  Created by Brian Hardy on 6/21/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BNRCar : NSManagedObject

@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * make;
@property (nonatomic, retain) NSString * model;
@property (nonatomic) int64_t rgbColor;
@property (nonatomic) int16_t year;

+ (BNRCar *)insertCarInManagedObjectContext:(NSManagedObjectContext *)moc;
- (NSString *)userDescription;

@end
