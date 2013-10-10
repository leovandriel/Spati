//
//  WDSHTTPCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSCache.h"

@class WDSParser;


@interface WDSHTTPCache : NSObject

@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) NSOperationQueue *queue;
@property (nonatomic, readonly) WDSCache *cache;

- (id)initWithCache:(WDSCache *)cache;
- (id)initWithCache:(WDSCache *)cache concurrent:(NSUInteger)concurrent;
- (id)initWithCache:(WDSCache *)cache queue:(NSOperationQueue *)queue;
- (id)objectForKey:(NSString *)key force:(BOOL)force block:(void(^)(id object, BOOL cancelled))block;
- (id)dataForKey:(NSString *)key force:(BOOL)force block:(void(^)(NSData *data, BOOL cancelled))block;
- (void)forceFetchForKey:(NSString *)key;

@end
