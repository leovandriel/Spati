//
//  WDSProxyCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSCache.h"


@interface WDSProxyCache : WDSCache

@property (nonatomic, readonly) WDSCache *cache;

- (id)initWithCache:(WDSCache *)cache;

@end
