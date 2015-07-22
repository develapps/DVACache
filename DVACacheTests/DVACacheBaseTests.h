//
//  DVACacheTest.h
//  DVACache
//
//  Created by Pablo Romeu on 22/7/15.
//  Copyright (c) 2015 Pablo Romeu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DVACache.h"

extern const int bigNumber;

@interface DVACacheBaseTests : XCTestCase
@property (nonatomic,strong) DVACache*cache;
@property (nonatomic) int objectsNumber;

-(void)populateWithPersistance:(DVACachePersistance)persistance andLifetime:(NSTimeInterval)timeinterval;
@end
