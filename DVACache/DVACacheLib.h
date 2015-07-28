//
//  DVACacheLib.h
//  coredataTest
//
//  Created by Pablo Romeu on 15/7/15.
//  Copyright © 2015 Pablo Romeu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVACacheObject.h"

#pragma mark - DVACache

typedef enum : NSUInteger {
    DVACacheDebugNone       = 0,
    DVACacheDebugLow        = 1,
    DVACacheDebugHigh       = 2,
} DVACacheDebugLevel;


@protocol DVACacheDelegate;

@interface DVACache : NSObject
@property (nonatomic)       BOOL                                enabled;
@property (nonatomic,weak)  __nullable id<DVACacheDelegate>     delegate;
@property (nonatomic)       DVACacheDebugLevel                  debug;
@property (nonatomic)       NSTimeInterval                      defaultEvictionTime;
@property (nonatomic)       DVACachePersistance                 defaultPersistance;

// A shared instance uses dvacache bundle identifier.
+ (nonnull instancetype)sharedInstance;

// If you want a specific cache for a kind of object, use a named cache.
- (nullable instancetype)initWithName:(nonnull NSString*)cacheName;

#pragma mark - setter/getter with a cache object

- (void)setCacheObject:(nonnull DVACacheObject*)object forKey:(nonnull NSString*)aKey;
- (DVACacheObject* __nullable)cacheObjectForKey:(nonnull NSString*)aKey;


#pragma mark - convenience setter/getter

- (void)setObject:(nonnull id  <NSCoding>)object forKey:(nonnull NSString*)aKey;
- (__nullable id<NSCoding>)objectForKey:(nonnull NSString*)aKey;


#pragma mark - Async getter/setters

// For big objects, better call this. Completion block will be called on main thread

- (void)cacheObjectForKey:(nonnull NSString*)aKey withCompletionBlock:(void (^ __nonnull)( DVACacheObject* __nullable ))completion;
- (void)setCacheObject:(nonnull DVACacheObject*)object forKey:(nonnull NSString*)aKey withCompletionBlock:(void (^ __nonnull)())completion;

- (void)objectForKey:(nonnull NSString*)aKey withCompletionBlock:(void (^ __nonnull)( id<NSCoding> __nullable ))completion;
- (void)setObject:(nonnull id  <NSCoding>)object forKey:(nonnull NSString*)aKey withCompletionBlock:(void (^ __nonnull)())completion;


#pragma mark - cleanup

-(void)removeAllMemoryCachedData;
-(void)removeAllDiskCachedData;

@end


#pragma mark - DVACacheDelegate

@protocol DVACacheDelegate <NSObject>

-(void)cacheWillEvictObjectsForKeys:(NSArray* __nonnull)keysArray fromPersistanceCache:(DVACachePersistance)cache;

@end


