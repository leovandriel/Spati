//
//  WDSProxyCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSProxyCache.h"


@implementation WDSProxyCache

- (id)initWithCache:(WDSCache *)cache
{
    self = [super init];
    if (self) {
        _cache = cache;
    }
    return self;
}

- (void)objectForKey:(NSString *)key dataOnly:(BOOL)dataOnly block:(void (^)(id))block
{
    [_cache objectForKey:key dataOnly:dataOnly block:block];
}

- (void)setObject:(id)object forKey:(NSString *)key dataOnly:(BOOL)dataOnly block:(void(^)(BOOL))block
{
    [_cache setObject:object forKey:key dataOnly:dataOnly block:block];
}

- (void)removeObjectForKey:(NSString *)key block:(void(^)(BOOL))block
{
    [_cache removeObjectForKey:key block:block];
}

- (void)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey block:(void(^)(BOOL))block
{
    [_cache moveObjectForKey:key toKey:toKey block:block];
}

- (void)removeAllObjectsWithBlock:(void (^)(BOOL))block
{
    [_cache removeAllObjectsWithBlock:block];
}


@end
