//
//  WDSDiskCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSCache.h"


@interface WDSDiskCache : WDSCache

@property (nonatomic, readonly) NSTimeInterval expires;
@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) unsigned long long size;

- (id)init;
- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name expires:(NSTimeInterval)expires;

@end
