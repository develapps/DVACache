//
//  DVACacheMixedTests.m
//  DVACache
//
//  Created by Pablo Romeu on 22/7/15.
//  Copyright (c) 2015 Pablo Romeu. All rights reserved.
//

#import "DVACacheBaseTests.h"

@interface DVACacheMixedTests : DVACacheBaseTests

@end

@implementation DVACacheMixedTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - mixed tests

- (void)testInMemoryAndOnDiskAsyncCache{
    [self populateWithPersistance:DVACacheOnDisk|DVACacheInMemory andLifetime:3000];
    
    for (int i=0; i<self.objectsNumber; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        XCTestExpectation*expectation=[self expectationWithDescription:akey];
        [self.cache cacheObjectForKey:akey withCompletionBlock:^(DVACacheObject * cachedObject) {
            XCTAssert(cachedObject,@"This object should exist: Key%i",i);
            XCTAssert([(NSObject*)cachedObject.cachedData isKindOfClass:[NSDictionary class]],@"This object should be an NSDictionary: Key%i",i);
            XCTAssert(cachedObject.persistance & (DVACacheInMemory|DVACacheOnDisk), @"This object should have both in-memory and on-disk persistance: Key%i",i);
            [expectation fulfill];
        }];
    }
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testMixedAsyncCacheEviction{
    [self populateWithPersistance:DVACacheInMemory|DVACacheOnDisk andLifetime:2];
    
    for (int i=0; i<self.objectsNumber; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        XCTestExpectation*expectation=[self expectationWithDescription:akey];
        [self.cache objectForKey:akey withCompletionBlock:^(id<NSCoding> object) {
            NSObject*cachedObject=(NSObject*)object;
            XCTAssert(cachedObject,@"This object should exist: Key%i",i);
            XCTAssert([cachedObject isKindOfClass:[NSDictionary class]],@"This object should be an NSDictionary: Key%i",i);
            [expectation fulfill];
        }];
    }
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    [NSThread sleepForTimeInterval:3];
    
    // Cache should have evicted
    // It should be empty now
    
    for (int i=0; i<self.objectsNumber; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        XCTestExpectation*expectation=[self expectationWithDescription:akey];
        [self.cache objectForKey:akey withCompletionBlock:^(id<NSCoding> object) {
            NSObject*cachedObject=(NSObject*)object;
            XCTAssert(cachedObject==nil,@"This object should not exist: Key%i",i);
            [expectation fulfill];
        }];
    }
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
}


-(void)testOnDiskToMemoryRetriveral{
    [self populateWithPersistance:DVACacheOnDisk andLifetime:3600];
    
    // Operating System caches disk calls, so first always is slower.
    for (int i=0; i<self.objectsNumber; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        [self.cache objectForKey:akey];
    }
    
    for (int i=0; i<self.objectsNumber; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        DVACacheObject*cachedObject=[self.cache cacheObjectForKey:akey];
        XCTAssert(cachedObject,@"This object should exist: Key%i",i);
        XCTAssert([(NSObject*)cachedObject.cachedData isKindOfClass:[NSDictionary class]],@"This object should be an NSDictionary: Key%i",i);
        XCTAssert((cachedObject.persistance & DVACacheInMemory), @"This object should have an in-memory persistance type.");
    }
}
@end
