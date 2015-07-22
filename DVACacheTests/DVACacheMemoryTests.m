//
//  DVACacheMemoryTests.m
//  DVACache
//
//  Created by Pablo Romeu on 22/7/15.
//  Copyright (c) 2015 Pablo Romeu. All rights reserved.
//

#import "DVACacheBaseTests.h"

@interface DVACacheMemoryTests : DVACacheBaseTests <DVACacheDelegate>
@property (nonatomic,strong) XCTestExpectation*delegateExpectation;
@end

@implementation DVACacheMemoryTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.cache.delegate=self;

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.delegateExpectation=nil;
    self.cache.delegate=nil;
    [super tearDown];
}

#pragma mark - Memory Tests

- (void)testInMemoryCache{
    [self populateWithPersistance:DVACacheInMemory andLifetime:3000];
    for (int i=0; i<self.objectsNumber; i++) {
        id cachedObject=[self.cache objectForKey:[NSString stringWithFormat:@"Key%i",i]];
        XCTAssert(cachedObject,@"This object should exist: Key%i",i);
        XCTAssert([cachedObject isKindOfClass:[NSDictionary class]],@"This object should be an NSDictionary: Key%i",i);
    }
}

- (void)testInMemoryCacheEviction{
    [self populateWithPersistance:DVACacheInMemory andLifetime:2];
    for (int i=0; i<self.objectsNumber; i++) {
        id cachedObject=[self.cache objectForKey:[NSString stringWithFormat:@"Key%i",i]];
        XCTAssert(cachedObject,@"This object should exist: Key%i",i);
        XCTAssert([cachedObject isKindOfClass:[NSDictionary class]],@"This object should be an NSDictionary: Key%i",i);
    }
    [NSThread sleepForTimeInterval:3];
    for (int i=0; i<self.objectsNumber; i++) {
        id cachedObject=[self.cache objectForKey:[NSString stringWithFormat:@"Key%i",i]];
        XCTAssert(cachedObject,@"This object should still exist: Key%i",i);
        XCTAssert([cachedObject isKindOfClass:[NSDictionary class]],@"This object should still be an NSDictionary: Key%i",i);
    }
    
    for (int i=0; i<self.objectsNumber; i++) {
        id cachedObject=[self.cache objectForKey:[NSString stringWithFormat:@"Key%i",i]];
        XCTAssert(cachedObject==nil,@"This object should not exist: Key%i",i);
    }
    
}

#pragma mark - In memory performance

- (void)testInMemoryLoadPerformance {
    // This is an example of a performance test case.
    self.objectsNumber=10*bigNumber;
    self.cache.debug=DVACacheDebugNone;
    [self measureBlock:^{
        [self populateWithPersistance:DVACacheInMemory andLifetime:3600];
    }];
}
- (void)testInMemoryRetrieveralPerformance {
    // This is an example of a performance test case.
    self.objectsNumber=10*bigNumber;
    self.cache.debug=DVACacheDebugNone;
    [self populateWithPersistance:DVACacheInMemory andLifetime:3600];
    [self measureBlock:^{
        for (int i=0; i<self.objectsNumber; i++) {
            id cachedObject=[self.cache objectForKey:[NSString stringWithFormat:@"Key%i",i]];
            XCTAssert(cachedObject,@"This object should exist: Key%i",i);
        }
    }];
}

#pragma mark - Memory Warning

-(void)testCacheEvictionAtMemoryWarning{
    self.objectsNumber=bigNumber*10;
    self.cache.debug=DVACacheDebugNone;
    [self populateWithPersistance:DVACacheInMemory andLifetime:3600];
    self.delegateExpectation=[self expectationWithDescription:@"delegate"];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object: [UIApplication sharedApplication]];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i=0; i<self.objectsNumber; i++) {
            NSString * akey=[NSString stringWithFormat:@"Key%i",i];
            DVACacheObject*cachedObject=[self.cache cacheObjectForKey:akey];
            XCTAssert(cachedObject==nil,@"This object should not exist: Key%i",i);
        }
    });
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

-(void)cacheWillEvictObjectsForKeys:(NSArray * __nonnull)keysArray fromPersistanceCache:(DVACachePersistance)cache{
    if (self.cache.debug>DVACacheDebugNone) NSLog(@"DVACACHE: EVICTING %lu keys",(unsigned long)[keysArray count]);
    if (self.delegateExpectation) {
        [self.delegateExpectation fulfill];
    }
}

@end
