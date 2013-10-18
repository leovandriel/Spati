//
//  WDSMemoryDiskCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSMemoryDiskCache.h"
#import "WDSMemoryCache.h"
#import "WDSDiskCache.h"
#import "WDSParser.h"


@implementation WDSMemoryDiskCache

- (id)init
{
    return [self initWithName:@"WDSMemoryDiskCache"];
}

- (id)initWithName:(NSString *)name
{
    return [self initWithName:name parser:nil expires:0];
}

- (id)initWithName:(NSString *)name parser:(WDSParser *)parser expires:(NSTimeInterval)expires
{
    WDSMemoryCache *memoryCache = [[WDSMemoryCache alloc] initWithName:name];
    WDSDiskCache *diskCache = [[WDSDiskCache alloc] initWithName:name expires:expires];
    return [self initWithMemoryCache:memoryCache diskCache:diskCache parser:parser];
}

- (id)initWithMemoryCache:(WDSMemoryCache *)memoryCache diskCache:(WDSDiskCache *)diskCache parser:(WDSParser *)parser
{
    self = [super initWithCaches:@[memoryCache, diskCache]];
    if (self) {
        _memoryCache = memoryCache;
        _diskCache = diskCache;
        _parser = parser;
    }
    return self;
}

- (id)objectForKey:(NSString *)key dataOnly:(BOOL)dataOnly
{
    if (dataOnly) {
        NSData *result = [_diskCache objectForKey:key dataOnly:YES];
        if (!result && _parser) result = [_parser serialize:[_memoryCache objectForKey:key dataOnly:NO]];
        return result;
    } else {
        NSData *result = [_memoryCache objectForKey:key dataOnly:NO];
        if (!result && _parser) result = [_parser parse:[_diskCache objectForKey:key dataOnly:YES]];
        return result;
    }
}

@end
