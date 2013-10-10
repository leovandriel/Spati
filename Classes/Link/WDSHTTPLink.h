//
//  WDSHTTPLink.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDSCache.h"

@class WDSParser;


@interface WDSHTTPLink : NSObject

@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) NSOperationQueue *queue;
@property (nonatomic, readonly) WDSCache *cache;

- (id)initWithCache:(WDSCache *)cache;
- (id)initWithCache:(WDSCache *)cache concurrent:(NSUInteger)concurrent;
- (id)initWithCache:(WDSCache *)cache queue:(NSOperationQueue *)queue;

- (void)forceFetchForRequest:(NSURLRequest *)request;

- (id)objectForURL:(NSURL *)url force:(BOOL)force block:(void(^)(id object, BOOL cancelled))block;
- (id)dataForURL:(NSURL *)url force:(BOOL)force block:(void(^)(NSData *data, BOOL cancelled))block;
- (id)objectForRequest:(NSURLRequest *)request force:(BOOL)force block:(void(^)(id object, BOOL cancelled))block;
- (id)dataForRequest:(NSURLRequest *)request force:(BOOL)force block:(void(^)(NSData *data, BOOL cancelled))block;

@end
