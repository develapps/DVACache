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

@interface DVACache : NSObject

@property (nonatomic) DVACacheDebugLevel debug;

+ (nonnull instancetype)sharedInstance;


#pragma mark - setter/getter with a cache object

- (void)setCacheObject:(nonnull DVACacheObject*)object forKey:(nonnull NSString*)aKey;
- (DVACacheObject* __nullable)cacheObjectForKey:(nonnull NSString*)aKey;

// For big objects, better call this. Completion blocks will be called on main thread
- (void)cacheObjectForKey:(nonnull NSString*)aKey withCompletionBlock:(void (^ __nonnull)( DVACacheObject* __nullable ))completion;
- (void)setCacheObject:(nonnull DVACacheObject*)object forKey:(nonnull NSString*)aKey withCompletionBlock:(void (^ __nonnull)())completion;

#pragma mark - convenience setter/getter

- (void)setObject:(nonnull id  <NSCoding>)object forKey:(nonnull NSString*)aKey;
- (__nullable id<NSCoding>)objectForKey:(nonnull NSString*)aKey;

// For big objects, better call this. Completion block will be called on main thread
- (void)objectForKey:(nonnull NSString*)aKey withCompletionBlock:(void (^ __nonnull)( id<NSCoding> __nullable ))completion;
- (void)setObject:(nonnull id  <NSCoding>)object forKey:(nonnull NSString*)aKey withCompletionBlock:(void (^ __nonnull)())completion;


#pragma mark - cleanup

-(void)removeAllMemoryCachedData;
-(void)removeAllDiskCachedData;

@end
