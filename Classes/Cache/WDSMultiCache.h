//
//  WDSMultiCache.h
//  Spati
//
//  Copyright (c) 2013 witdot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSCache.h"

@interface WDSMultiCache : WDSCache

@property (nonatomic, readonly) NSArray *caches;

- (id)initWithCaches:(NSArray *)caches;

@end
