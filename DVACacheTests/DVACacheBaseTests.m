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



@end
