//
//  WDSHTTPCache.h
//  Spati
//
//  Copyright (c) 2013 witdot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSMultiCache.h"

@class WDSParser;


@interface WDSHTTPCache : WDSMultiCache

@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) NSOperationQueue *queue;

- (id)initWithCaches:(NSArray *)caches parser:(WDSParser *)parser;
- (id)initWithCaches:(NSArray *)caches parser:(WDSParser *)parser concurrent:(NSUInteger)concurrent;
- (id)initWithCaches:(NSArray *)caches parser:(WDSParser *)parser queue:(NSOperationQueue *)queue;
- (id)objectForKey:(NSString *)key force:(BOOL)force block:(void(^)(id object, BOOL cancelled))block;
- (id)dataForKey:(NSString *)key force:(BOOL)force block:(void(^)(NSData *data, BOOL cancelled))block;
- (void)forceFetchForKey:(NSString *)key;

@end
