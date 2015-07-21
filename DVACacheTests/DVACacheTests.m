//
//  DVACacheTests.m
//  DVACacheTests
//
//  Created by Pablo Romeu on 21/7/15.
//  Copyright (c) 2015 Pablo Romeu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DVACache.h"


const int bigNumber=1000;

@interface DVACacheTests : XCTestCase
@property (nonatomic,strong) DVACache*cache;
@property (nonatomic) int objectsNum;
@end


@implementation DVACacheTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _cache=[DVACache new];
    _cache.debug=DVACacheDebugHigh;
    _objectsNum=1;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [_cache removeAllDiskCachedData];
    [super tearDown];
}


#pragma mark - helpers

-(void)populateWithPersistance:(DVACachePersistance)persistance andLifetime:(NSTimeInterval)timeinterval{
    for (int i=0; i<_objectsNum; i++) {
        NSDictionary*dict=@{ @"this is a test object" : [NSString stringWithFormat:@"with a test key %i",i] };
        DVACacheObject*co=[[DVACacheObject alloc] initWithData:dict andLifetime:timeinterval andPersistance:persistance];
        [self.cache setCacheObject:co forKey:[NSString stringWithFormat:@"Key%i",i]];
    }
}

#pragma mark - Memory Tests

- (void)testInMemoryCache{
    [self populateWithPersistance:DVACacheInMemory andLifetime:3000];
    for (int i=0; i<_objectsNum; i++) {
        id cachedObject=[self.cache objectForKey:[NSString stringWithFormat:@"Key%i",i]];
        XCTAssert(cachedObject,@"This object should exist: Key%i",i);
        XCTAssert([cachedObject isKindOfClass:[NSDictionary class]],@"This object should be an NSDictionary: Key%i",i);
    }
}

- (void)testInMemoryCacheEviction{
    [self populateWithPersistance:DVACacheInMemory andLifetime:2];
    for (int i=0; i<_objectsNum; i++) {
        id cachedObject=[self.cache objectForKey:[NSString stringWithFormat:@"Key%i",i]];
        XCTAssert(cachedObject,@"This object should exist: Key%i",i);
        XCTAssert([cachedObject isKindOfClass:[NSDictionary class]],@"This object should be an NSDictionary: Key%i",i);
    }
    [NSThread sleepForTimeInterval:3];
    for (int i=0; i<_objectsNum; i++) {
        id cachedObject=[self.cache objectForKey:[NSString stringWithFormat:@"Key%i",i]];
        XCTAssert(cachedObject,@"This object should still exist: Key%i",i);
        XCTAssert([cachedObject isKindOfClass:[NSDictionary class]],@"This object should still be an NSDictionary: Key%i",i);
    }
    
    for (int i=0; i<_objectsNum; i++) {
        id cachedObject=[self.cache objectForKey:[NSString stringWithFormat:@"Key%i",i]];
        XCTAssert(cachedObject==nil,@"This object should not exist: Key%i",i);
    }

}

#pragma mark - Disk Tests

- (void)testOnDiskAsyncCache{
    [self populateWithPersistance:DVACacheOnDisk andLifetime:3000];

    for (int i=0; i<_objectsNum; i++) {
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
    
    for (int i=0; i<_objectsNum; i++) {
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
    
    for (int i=0; i<_objectsNum; i++) {
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
    
    for (int i=0; i<_objectsNum; i++) {
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

#pragma mark - mixed tests

- (void)testInMemoryAndOnDiskAsyncCache{
    [self populateWithPersistance:DVACacheOnDisk|DVACacheInMemory andLifetime:3000];
    
    for (int i=0; i<_objectsNum; i++) {
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
    
    for (int i=0; i<_objectsNum; i++) {
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
    
    // Cache should evict now
    
    for (int i=0; i<_objectsNum; i++) {
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
    
    for (int i=0; i<_objectsNum; i++) {
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
    for (int i=0; i<_objectsNum; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        [self.cache objectForKey:akey];
    }
    
    for (int i=0; i<_objectsNum; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        DVACacheObject*cachedObject=[self.cache cacheObjectForKey:akey];
        XCTAssert(cachedObject,@"This object should exist: Key%i",i);
        XCTAssert([(NSObject*)cachedObject.cachedData isKindOfClass:[NSDictionary class]],@"This object should be an NSDictionary: Key%i",i);
        XCTAssert((cachedObject.persistance & DVACacheInMemory), @"This object should have an in-memory persistance type.");
    }
}

#pragma mark - Memory Warning

-(void)testCacheEvictionAtMemoryWarning{
    _objectsNum=bigNumber*10;
    _cache.debug=DVACacheDebugNone;
    [self populateWithPersistance:DVACacheInMemory andLifetime:3600];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object: [UIApplication sharedApplication]];
    
    for (int i=0; i<_objectsNum; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        DVACacheObject*cachedObject=[self.cache cacheObjectForKey:akey];
        XCTAssert(cachedObject==nil,@"This object should not exist: Key%i",i);
    }
}

#pragma mark - In memory performance

- (void)testInMemoryLoadPerformance {
    // This is an example of a performance test case.
    _objectsNum=10*bigNumber;
    _cache.debug=DVACacheDebugNone;
    [self measureBlock:^{
        [self populateWithPersistance:DVACacheInMemory andLifetime:3600];
    }];
}
- (void)testInMemoryRetrieveralPerformance {
    // This is an example of a performance test case.
    _objectsNum=10*bigNumber;
    _cache.debug=DVACacheDebugNone;
    [self populateWithPersistance:DVACacheInMemory andLifetime:3600];
    [self measureBlock:^{
        for (int i=0; i<_objectsNum; i++) {
            id cachedObject=[self.cache objectForKey:[NSString stringWithFormat:@"Key%i",i]];
            XCTAssert(cachedObject,@"This object should exist: Key%i",i);
        }
    }];
}

#pragma mark - On Disk performance

-(void)testOnDiskLoadPerformance {
    // This is an example of a performance test case.
    _objectsNum=bigNumber;
    _cache.debug=DVACacheDebugNone;
    [self measureBlock:^{
       [self populateWithPersistance:DVACacheOnDisk andLifetime:3600];
    }];
}

-(void)testOnDiskRetriveralPerformance {
    // This is an example of a performance test case.
    _objectsNum=bigNumber;
    _cache.debug=DVACacheDebugNone;
    [self populateWithPersistance:DVACacheOnDisk andLifetime:3600];

    // Operating System caches disk calls, so first always is slower.
    for (int i=0; i<_objectsNum; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        [self.cache objectForKey:akey];
    }
    
    [self measureBlock:^{
        [self.cache removeAllMemoryCachedData];
        for (int i=0; i<_objectsNum; i++) {
            NSString * akey=[NSString stringWithFormat:@"Key%i",i];
            [self.cache objectForKey:akey];
        }
    }
    ];
}

-(void)testOnDiskMemoryRetriveralPerformance {
    _objectsNum=bigNumber;
    _cache.debug=DVACacheDebugNone;
    [self populateWithPersistance:DVACacheOnDisk andLifetime:3600];
    
    // Operating System caches disk calls, so first always is slower.
    for (int i=0; i<_objectsNum; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        [self.cache objectForKey:akey];
    }
    
    [self measureBlock:^{
        // This should be blazing fast
        for (int i=0; i<_objectsNum; i++) {
            NSString * akey=[NSString stringWithFormat:@"Key%i",i];
            [self.cache objectForKey:akey];
        }
    }
     ];
}
@end
