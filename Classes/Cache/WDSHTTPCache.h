//
//  WDSHTTPCache.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSMultiCache.h"

@class WDSParser;


@interface WDSHTTPCache : WDSMultiCache

@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) NSOperationQueue *queue;

- (id)initWithCaches:(NSArray *)caches;
- (id)initWithCaches:(NSArray *)caches concurrent:(NSUInteger)concurrent;
- (id)initWithCaches:(NSArray *)caches queue:(NSOperationQueue *)queue;
- (id)objectForKey:(NSString *)key force:(BOOL)force block:(void(^)(id object, BOOL cancelled))block;
- (id)dataForKey:(NSString *)key force:(BOOL)force block:(void(^)(NSData *data, BOOL cancelled))block;
- (void)forceFetchForKey:(NSString *)key;

@end
