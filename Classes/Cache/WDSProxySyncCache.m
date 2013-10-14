//
//  WDSProxySyncCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSProxySyncCache.h"


@implementation WDSProxySyncCache

- (id)initWithCache:(WDSSyncCache *)cache
{
    self = [super init];
    if (self) {
        _cache = cache;
    }
    return self;
}

- (id)objectForKey:(NSString *)key dataOnly:(BOOL)dataOnly
{
    return [_cache objectForKey:key dataOnly:dataOnly];
}

- (BOOL)setObject:(id)object forKey:(NSString *)key dataOnly:(BOOL)dataOnly
{
    return [_cache setObject:object forKey:key dataOnly:dataOnly];
}

- (BOOL)removeObjectForKey:(NSString *)key
{
    return [_cache removeObjectForKey:key];
}

- (BOOL)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey
{
    return [_cache moveObjectForKey:key toKey:toKey];
}

- (BOOL)removeAllObjects
{
    return [_cache removeAllObjects];
}

@end
