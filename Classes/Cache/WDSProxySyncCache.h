//
//  WDSProxySyncCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSSyncCache.h"


@interface WDSProxySyncCache : WDSSyncCache

@property (nonatomic, readonly) WDSSyncCache *cache;

- (id)initWithCache:(WDSSyncCache *)cache;

@end
