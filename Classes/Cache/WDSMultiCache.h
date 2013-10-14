//
//  WDSMultiCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSSyncCache.h"

@interface WDSMultiCache : WDSSyncCache

@property (nonatomic, readonly) NSArray *caches;

- (id)initWithCaches:(NSArray *)caches;

@end
