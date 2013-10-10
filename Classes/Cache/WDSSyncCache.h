//
//  WDSSyncCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSCache.h"


@interface WDSSyncCache : WDSCache

@property (nonatomic, readonly) dispatch_queue_t workQueue;
@property (nonatomic, readonly) dispatch_queue_t doneQueue;

- (id)objectForKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key;
- (BOOL)setObject:(id)object forKey:(NSString *)key;
- (BOOL)setData:(NSData *)data forKey:(NSString *)key;
- (BOOL)removeObjectForKey:(NSString *)key;
- (BOOL)moveObjectForKey:(NSString *)key toKey:(NSString *)toKey;
- (BOOL)removeAllObjects;

@end
