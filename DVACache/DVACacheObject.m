//
//  DVACacheObject.m
//  DVACache
//
//  Created by Pablo Romeu on 21/7/15.
//  Copyright (c) 2015 Pablo Romeu. All rights reserved.
//

#import "DVACacheObject.h"

@interface DVACacheObject ()
@property (nonatomic,strong) NSDate*evictTime;
@end


@implementation DVACacheObject

-(instancetype)init{
    if (self=[super init]) {
        _evictTime=[NSDate date];
        _persistance=DVACacheInMemory;
    }
    return self;
}

-(instancetype)initWithData:(id<NSCoding>)cachedData andLifetime:(NSTimeInterval)lifetime andPersistance:(DVACachePersistance)persistance{
    if (self=[super init]) {
        _evictTime=[NSDate dateWithTimeIntervalSinceNow:lifetime];
        _persistance=persistance;
        _cachedData=cachedData;
    }
    return self;
}

-(void)setLifetime:(NSTimeInterval)lifetime{
    self.evictTime=[NSDate dateWithTimeIntervalSinceNow:lifetime];
}

-(NSTimeInterval)lifetime{
    return [self.evictTime timeIntervalSinceNow];
}

#pragma mark - enconding

-(id)initWithCoder:(NSCoder*)decoder{
    self = [super init];
    if (self) {
        self.cachedData=[decoder decodeObjectForKey:@"cachedData"];
        self.evictTime = [decoder decodeObjectForKey:@"evictTime"];
        self.persistance = [[decoder decodeObjectForKey:@"persistance"] integerValue];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.cachedData forKey:@"cachedData"];
    [encoder encodeObject:self.evictTime forKey:@"evictTime"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.persistance] forKey:@"persistance"];
}

@end
