//
//  DVACacheObject.h
//  DVACache
//
//  Created by Pablo Romeu on 21/7/15.
//  Copyright (c) 2015 Pablo Romeu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    DVACacheOnDisk          = 1 << 0,
    DVACacheInMemory        = 1 << 1,
} DVACachePersistance;

@interface DVACacheObject : NSObject <NSCoding>
@property (nonatomic,strong)    __nonnull id  <NSCoding>cachedData;
@property (nonatomic)           NSTimeInterval lifetime;
@property (nonatomic)           DVACachePersistance persistance;

-(nonnull instancetype)initWithData:(nullable id<NSCoding>)cachedData andLifetime:(NSTimeInterval)lifetime andPersistance:(DVACachePersistance)persistance;

@end
