//
//  WDSMemoryCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSCache.h"
#import "WDSSyncStorePipe.h"


@interface WDSMemoryCache : WDSCache

@property (nonatomic, readonly) NSCache *cache;
@property (nonatomic, readonly) NSUInteger(^costBlock)(id);
@property (nonatomic, readonly) NSString *name;

- (instancetype)init;
- (instancetype)initWithName:(NSString *)name;

@end
