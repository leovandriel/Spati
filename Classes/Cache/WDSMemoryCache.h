//
//  WDSMemoryCache.h
//  Spati
//
//  Copyright (c) 2013 witdot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSCache.h"


@interface WDSMemoryCache : WDSCache

@property (nonatomic, readonly) NSCache *cache;
@property (nonatomic, readonly) WDSParser *parser;

- (id)init;
- (id)initWithParser:(WDSParser *)parser;

@end
