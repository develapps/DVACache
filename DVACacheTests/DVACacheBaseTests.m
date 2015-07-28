//
//  DVACacheTest.m
//  DVACache
//
//  Created by Pablo Romeu on 22/7/15.
//  Copyright (c) 2015 Pablo Romeu. All rights reserved.
//

#import "DVACacheBaseTests.h"

const int bigNumber=1000;

@implementation DVACacheBaseTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _cache=[DVACache new];
    _cache.debug=DVACacheDebugHigh;
    _objectsNumber=1;
    self.cache.enabled=YES;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [_cache removeAllDiskCachedData];
    [super tearDown];
}


#pragma mark - helpers

-(void)populateWithPersistance:(DVACachePersistance)persistance andLifetime:(NSTimeInterval)timeinterval{
    for (int i=0; i<self.objectsNumber; i++) {
        NSDictionary*dict=@{ @"this is a test object" : [NSString stringWithFormat:@"with a test key %i",i] };
        DVACacheObject*co=[[DVACacheObject alloc] initWithData:dict andLifetime:timeinterval andPersistance:persistance];
        [self.cache setCacheObject:co forKey:[NSString stringWithFormat:@"Key%i",i]];
    }
}

#pragma mark - test disabled

-(void)testCacheObjectDisabled{
    self.cache.enabled=NO;
    [self populateWithPersistance:DVACacheInMemory andLifetime:3000];
    for (int i=0; i<self.objectsNumber; i++) {
        id cachedObject=[self.cache cacheObjectForKey:[NSString stringWithFormat:@"Key%i",i]];
        XCTAssert(cachedObject==nil,@"This object should not exist, because cache is disabled: Key%i",i);
    }
}

-(void)testObjectDisabled{
    self.cache.enabled=NO;
    [self populateWithPersistance:DVACacheInMemory andLifetime:3000];
    for (int i=0; i<self.objectsNumber; i++) {
        id cachedObject=[self.cache objectForKey:[NSString stringWithFormat:@"Key%i",i]];
        XCTAssert(cachedObject==nil,@"This object should not exist, because cache is disabled: Key%i",i);
    }
}

-(void)testCacheObjectAsyncDisabled{
    self.cache.enabled=NO;
    [self populateWithPersistance:DVACacheInMemory andLifetime:3000];
    for (int i=0; i<self.objectsNumber; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        XCTestExpectation*expectation=[self expectationWithDescription:akey];
        [self.cache cacheObjectForKey:akey withCompletionBlock:^(DVACacheObject * cachedObject) {
            XCTAssert(cachedObject==nil,@"This object NOT should exist: Key%i",i);
            [expectation fulfill];
        }];
    }
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

-(void)testObjectAsyncDisabled{
    self.cache.enabled=NO;
    [self populateWithPersistance:DVACacheInMemory andLifetime:3000];
    for (int i=0; i<self.objectsNumber; i++) {
        NSString * akey=[NSString stringWithFormat:@"Key%i",i];
        XCTestExpectation*expectation=[self expectationWithDescription:akey];
        [self.cache objectForKey:akey withCompletionBlock:^(id<NSCoding> cachedObject) {
            XCTAssert(cachedObject==nil,@"This object NOT should exist: Key%i",i);
            [expectation fulfill];
        }];
    }
    [self waitForExpectationsWithTimeout:5 handler:nil];
}
@end
