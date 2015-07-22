//
//  DVACacheDiskTests.m
//  DVACache
//
//  Created by Pablo Romeu on 22/7/15.
//  Copyright (c) 2015 Pablo Romeu. All rights reserved.
//

#import "DVACacheBaseTests.h"

@interface DVACacheDiskTests : DVACacheBaseTests

@end

@implementation DVACacheDiskTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - Disk Tests

- (void)testOnDiskAsyncCache{
    [self populateWithPersistance:DVACacheOnDisk andLifetime:3000];
    
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
}

- (void)testOnDiskAsyncCacheEviction{
    [self populateWithPersistance:DVACacheOnDisk andLifetime:2];
    
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
    
    // Cache should have been evicted
    
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


#pragma mark - On Disk performance

-(void)testOnDiskLoadPerformance {
    // This is an example of a performance test case.
    self.objectsNumber=bigNumber;
    self.cache.debug=DVACacheDebugNone;
    [self measureBlock:^{
        [self populateWithPersistance:DVACacheOnDisk andLifetime:3600];
    }];
}

-(void)testOnDiskRetriveralPerformance {
    // This is an example of a performance test case.
    self.objectsNumber=bigNumber;
    self.cache.debug=DVACacheDebugNone;
    [self populateWithPersistance:DVACacheOnDisk andLifetime:3600];
    
    // Operating System caches disk calls, so first always is slower.
    for (int i=0; i<self.objectsNumber; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        [self.cache objectForKey:akey];
    }
    
    [self measureBlock:^{
        [self.cache removeAllMemoryCachedData];
        for (int i=0; i<self.objectsNumber; i++) {
            NSString * akey=[NSString stringWithFormat:@"Key%i",i];
            [self.cache objectForKey:akey];
        }
    }
     ];
}

-(void)testOnDiskMemoryRetriveralPerformance {
    self.objectsNumber=bigNumber;
    self.cache.debug=DVACacheDebugNone;
    [self populateWithPersistance:DVACacheOnDisk andLifetime:3600];
    
    // Operating System caches disk calls, so first always is slower.
    for (int i=0; i<self.objectsNumber; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        [self.cache objectForKey:akey];
    }
    
    [self measureBlock:^{
        // This should be blazing fast
        for (int i=0; i<self.objectsNumber; i++) {
            NSString * akey=[NSString stringWithFormat:@"Key%i",i];
            [self.cache objectForKey:akey];
        }
    }
     ];
}

@end
