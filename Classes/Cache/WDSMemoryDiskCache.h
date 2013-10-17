//
//  WDSMemoryDiskCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSMultiCache.h"

@class WDSDiskCache, WDSMemoryCache, WDSParser;


@interface WDSMemoryDiskCache : WDSMultiCache

@property (nonatomic, readonly) WDSMemoryCache *memoryCache;
@property (nonatomic, readonly) WDSDiskCache *diskCache;

- (id)init;
- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name parser:(WDSParser *)parser expires:(NSTimeInterval)expires;
- (id)initWithMemoryCache:(WDSMemoryCache *)memoryCache diskCache:(WDSDiskCache *)diskCache;

@end
