//
//  DVACacheLib.m
//  coredataTest
//
//  Created by Pablo Romeu on 15/7/15.
//  Copyright © 2015 Pablo Romeu. All rights reserved.
//

#import "DVACacheLib.h"
#import <DVACategories/NSString+DVALib.h>

#pragma mark - DVACACHE

@interface DVACache () 
@property (nonatomic,strong) NSMutableDictionary    *memCache;
@property (nonatomic,strong) NSString               *cacheName;

@end

@implementation DVACache

+ (instancetype)sharedInstance{
    static DVACache *_sharedInstace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstace = [DVACache new];
    });
    return _sharedInstace;
}

- (instancetype)initWithName:(NSString*)cacheName
{
    self = [self init];
    if (self) {
        self.cacheName=cacheName;
    }
    return self;
}

-(instancetype)init{
    if (self=[super init]) {
        _cacheName=[[NSBundle bundleForClass:[self class]] bundleIdentifier];
        _enabled=YES;
        _memCache=[[NSMutableDictionary alloc] init];
        _debug=DVACacheDebugNone;
        _defaultEvictionTime=300;
        _defaultPersistance=DVACacheInMemory;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllMemoryCachedData) name:UIApplicationDidReceiveMemoryWarningNotification object:[UIApplication sharedApplication]];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma - Setter & getter

- (nullable NSArray<NSString*>*)memCachedObjects{
    return [self.memCache allKeys];
}
- (nullable NSArray<NSString*>*)diskCachedObjects{
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cachePath] error:nil];

}

// Size of cache in MBytes

- (double)memSize{
    double size = 0;
    for (NSObject <NSCoding>*obj in [self.memCache  allValues]) {
        size += [[NSKeyedArchiver archivedDataWithRootObject:obj] length];
    }
    return size;
}
- (double)diskSize{
    double size = 0;
    for (NSString*obj in [self diskCachedObjects]) {
        size += [[[NSFileManager defaultManager] attributesOfItemAtPath:obj error:nil] fileSize];
    }
    return size;

}


-(void)setCacheObject:(DVACacheObject *)object forKey:(NSString*)aKey{
    if (object.persistance & DVACacheInMemory){
            if (_debug>DVACacheDebugNone) NSLog(@"DVACACHE: Caching in memory object for key %@",aKey);
        if ([self.delegate respondsToSelector:@selector(cache:willCacheObjectsForKeys:fromPersistanceCache:)]) {
            [self.delegate cache:self willCacheObjectsForKeys:@[object] fromPersistanceCache:DVACacheInMemory];
        }
            [self.memCache setObject:object forKey:aKey];
    }
    
    if (object.persistance & DVACacheOnDisk){
        if ([self.delegate respondsToSelector:@selector(cache:willCacheObjectsForKeys:fromPersistanceCache:)]) {
            [self.delegate cache:self willCacheObjectsForKeys:@[object] fromPersistanceCache:DVACacheOnDisk];
        }
            [self cacheDataOnDisk:object forKey:aKey];
    }
}



-(DVACacheObject*)cacheObjectForKey:(NSString*)aKey{
    if (!self.enabled) return nil;

    DVACacheObject*cachedObject=[self.memCache objectForKey:aKey];
    if (_debug>DVACacheDebugLow) NSLog(@"DVACACHE: Looking for in-memory object for key %@",aKey);
    if (!cachedObject) {
        if (_debug>DVACacheDebugLow) NSLog(@"DVACACHE: No object found, checking on-disk object for key %@",aKey);
        cachedObject=[self diskCachedDataForKey:aKey];
    }
    
    BOOL cleanedUp=[self cacheObjectCleanup:cachedObject forKey:aKey];
    
    if (!cleanedUp && cachedObject && !(cachedObject.persistance & DVACacheInMemory)) {
        // Also cache on memory
        if (_debug>DVACacheDebugLow) NSLog(@"DVACACHE: Found non-evicted on-disk object for key %@. Persisting in-memory cache",aKey);
        cachedObject.persistance= DVACacheOnDisk|DVACacheInMemory;
        [self setCacheObject:cachedObject forKey:aKey];
    }
    
    if (cachedObject && cachedObject.lifetime<=0) {
        if (_debug>DVACacheDebugNone) NSLog(@"DVACACHE: Found object for key %@ but lifetime was %.1f, returning nil",aKey,cachedObject.lifetime);
        return nil;
    }
    
    if (cachedObject) {
        if (_debug>DVACacheDebugNone) NSLog(@"DVACACHE: Found object for key %@. lifetime %.1f",aKey,cachedObject.lifetime);
        return cachedObject;
    }
    else{
        if (_debug>DVACacheDebugNone) NSLog(@"DVACACHE: Object for key %@ not found",aKey);
        return nil;
    }

}

-(void)removeCacheObjectForKey:(NSString *)aKey{
    if (_debug>DVACacheDebugLow) NSLog(@"DVACACHE: Removing Cache object for key %@",aKey);
    DVACacheObject*cachedObject=[self.memCache objectForKey:aKey];
    if (cachedObject) {
        if (_debug>DVACacheDebugHigh) NSLog(@"DVACACHE: Removing Cache object from memory for key %@",aKey);
        [self removeMemoryCachedDataForKey:aKey];
    }
    cachedObject=[self diskCachedDataForKey:aKey];
    if (cachedObject) {
        if (_debug>DVACacheDebugHigh) NSLog(@"DVACACHE: Removing Cache object from disk for key %@",aKey);
        [self removeDiskCachedDataForKey:aKey];
    }
}

- (void)cacheObjectForKey:(nonnull NSString*)aKey withCompletionBlock:(void (^ __nonnull)( DVACacheObject* __nullable ))completion{
    if (!self.enabled){
        completion(nil);
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        DVACacheObject*co=[self cacheObjectForKey:aKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(co);
        });
        
    });
}

- (void)setCacheObject:(nonnull DVACacheObject *)object forKey:(nonnull NSString *)aKey withCompletionBlock:(void (^ __nonnull)())completion{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self setCacheObject:object forKey:aKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
        
    });
}

#pragma mark - convenience methods

-(void)setObject:(nonnull id<NSCoding>)object forKey:(nonnull NSString *)aKey{
    DVACacheObject*cacheObject=[DVACacheObject new];
    
    // Just in memory
    cacheObject.persistance=self.defaultPersistance;
    cacheObject.cachedData=object;
    
    // One minute
    cacheObject.lifetime=self.defaultEvictionTime;
    [self setCacheObject:cacheObject forKey:aKey];
}

-(id<NSCoding>)objectForKey:(nonnull NSString*)aKey{
    DVACacheObject*cachedObject=[self cacheObjectForKey:aKey];
    return cachedObject?cachedObject.cachedData:nil;
}

-(void)removeObjectForKey:(NSString *)aKey{
    DVACacheObject*cachedObject=[self cacheObjectForKey:aKey];
    if (cachedObject) {
        [self removeCacheObjectForKey:aKey];
    }
}

-(void)objectForKey:(nonnull NSString *)aKey withCompletionBlock:(void (^ __nonnull)(id<NSCoding> __nullable))completion{
    [self cacheObjectForKey:aKey withCompletionBlock:^(DVACacheObject * object) {
        completion(object.cachedData);
    }];
}

-(void)setObject:(nonnull id<NSCoding>)object forKey:(nonnull NSString *)aKey withCompletionBlock:(void (^ __nonnull)())completion{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self setObject:object forKey:aKey];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            completion();
        });
    });
}


#pragma mark  - cleanup

-(BOOL)cacheObjectCleanup:(DVACacheObject*)cachedObject forKey:(NSString*)key{
    if (cachedObject && cachedObject.lifetime<=0) {
        if (_debug>DVACacheDebugNone) NSLog(@"DVACACHE: cleaning object for key %@",key);
        if (cachedObject.persistance & DVACacheInMemory) {
        if (_debug>DVACacheDebugLow) NSLog(@"DVACACHE: cleaning in-memory object for key %@",key);
            [self removeMemoryCachedDataForKey:key];
        }
        if (cachedObject.persistance & DVACacheOnDisk) {
        if (_debug>DVACacheDebugLow) NSLog(@"DVACACHE: cleaning on-disk object for key %@",key);
            [self removeDiskCachedDataForKey:key];
        }
        return YES;
    }
    return NO;
}

#pragma - memory persistance

-(void)removeAllMemoryCachedData{
    if (_debug>DVACacheDebugLow) NSLog(@"DVACACHE: Cleaning in memory cache");
    if ([self.delegate respondsToSelector:@selector(cache:willEvictObjectsForKeys:fromPersistanceCache:)]) {
        [self.delegate cache:self willEvictObjectsForKeys:[self.memCache allKeys] fromPersistanceCache:DVACacheInMemory];
    }
    [self.memCache removeAllObjects];
}


#pragma mark - memory removal base method

-(void)removeMemoryCachedDataForKey:(NSString*)aKey{
    if ([self.delegate respondsToSelector:@selector(cache:willEvictObjectsForKeys:fromPersistanceCache:)]) {
        [self.delegate cache:self willEvictObjectsForKeys:@[aKey] fromPersistanceCache:DVACacheInMemory];
    }
    [self.memCache removeObjectForKey:aKey];
}


#pragma - disk persistance

-(NSString*)cachePath{
    NSArray*urls=[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL*url=[urls firstObject];
    url=[url URLByAppendingPathComponent:[self.cacheName dva_generateMD5]];
    [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
    return [url path];
}

-(BOOL)removeDiskCachedDataForKey:(NSString*)aKey{
    if ([self.delegate respondsToSelector:@selector(cache:willEvictObjectsForKeys:fromPersistanceCache:)]) {
        [self.delegate cache:self willEvictObjectsForKeys:@[aKey] fromPersistanceCache:DVACacheOnDisk];
    }
    NSString*path=[[self cachePath] stringByAppendingPathComponent:[aKey dva_generateMD5]];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

-(void)removeAllDiskCachedData{

    NSArray*files=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self cachePath] error:nil];
    if (_debug>DVACacheDebugLow) NSLog(@"DVACACHE: Cleaning on-disk cache: %lu objects",(unsigned long)[files count]);
    if ([self.delegate respondsToSelector:@selector(cache:willEvictObjectsForKeys:fromPersistanceCache:)]) {
        [self.delegate cache:self willEvictObjectsForKeys:files fromPersistanceCache:DVACacheOnDisk];
    }
    for (NSString*file in files) {
        [[NSFileManager defaultManager] removeItemAtPath:[[self cachePath] stringByAppendingPathComponent:file] error:nil];
    }
}

-(void)cacheDataOnDisk:(DVACacheObject *)object forKey:(NSString*)aKey{
    NSString*path=[[self cachePath] stringByAppendingPathComponent:[aKey dva_generateMD5]];
    if (_debug>DVACacheDebugNone) NSLog(@"DVACACHE: Caching on disk object for key %@",aKey);
    else if (_debug>DVACacheDebugLow) NSLog(@"DVACACHE: Caching on disk object for key %@ at path %@",aKey,path);
    [NSKeyedArchiver archiveRootObject:object toFile:path];

}

-(DVACacheObject*)diskCachedDataForKey:(NSString*)aKey{
    NSString*path=[[self cachePath] stringByAppendingPathComponent:[aKey dva_generateMD5]];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

@end
