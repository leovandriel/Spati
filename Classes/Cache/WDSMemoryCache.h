//
//  WDSMemoryCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSSyncCache.h"

@class WDSParser;


@interface WDSMemoryCache : WDSSyncCache

@property (nonatomic, readonly) NSCache *cache;
@property (nonatomic, readonly) NSUInteger(^costBlock)(id);

- (id)init;
- (id)initWithName:(NSString *)name;

@end
