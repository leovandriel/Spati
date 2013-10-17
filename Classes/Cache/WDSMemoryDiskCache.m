//
//  WDSMemoryDiskCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSMemoryDiskCache.h"
#import "WDSMemoryCache.h"
#import "WDSDiskCache.h"


@implementation WDSMemoryDiskCache

- (id)init
{
    return [self initWithName:@"WDSMemoryDiskCache"];
}

- (id)initWithName:(NSString *)name
{
    return [self initWithName:name expires:0];
}

- (id)initWithName:(NSString *)name expires:(NSTimeInterval)expires
{
    WDSMemoryCache *memoryCache = [[WDSMemoryCache alloc] initWithName:name];
    WDSDiskCache *diskCache = [[WDSDiskCache alloc] initWithName:name expires:expires];
    return [self initWithMemoryCache:memoryCache diskCache:diskCache];
}

- (id)initWithMemoryCache:(WDSMemoryCache *)memoryCache diskCache:(WDSDiskCache *)diskCache
{
    self = [super initWithCaches:@[memoryCache, diskCache]];
    if (self) {
        _memoryCache = memoryCache;
        _diskCache = diskCache;
    }
    return self;
}

@end
