//
//  BNRCarPresenterTests.m
//  CarKeeper
//
//  Created by Brian Hardy on 12/3/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BNRCarPresenter.h"

@interface StubCar : NSObject

@property (nonatomic, readonly) NSString * nickname;
@property (nonatomic, readonly) NSString * make;
@property (nonatomic, readonly) NSString * model;
@property (nonatomic, readonly) int64_t rgbColor;
@property (nonatomic, readonly) int16_t year;

@end

@implementation StubCar

- (NSString *)nickname {
    return @"Old Betsy";
}

- (NSString *)make {
    return @"Ford";
}

- (NSString *)model {
    return @"Tardis";
}

- (int64_t)rgbColor {
    return 0x0101ff;
}

- (int16_t)year {
    return 1995;
}

@end

@interface BNRCarPresenterTests : XCTestCase

@end

@implementation BNRCarPresenterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDescriptionForCar {
    StubCar *stubCar = [StubCar new];
    
    BNRCarPresenter *presenter = [[BNRCarPresenter alloc] initWithCar:(BNRCar *)stubCar];
    
    XCTAssertEqualObjects(presenter.description, @"1995 Ford Tardis, \"Old Betsy\"");
    XCTAssertEqualObjects(presenter.color, [UIColor colorWithRed:0x01/255.0 green:0x01/255.0 blue:0xff/255.0 alpha:1]);
}
@end
