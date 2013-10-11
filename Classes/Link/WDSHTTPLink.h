//
//  WDSHTTPLink.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDSCache, WDSParser;


@interface WDSHTTPConnection : NSObject
- (void)cancel;
@end


@interface WDSHTTPSession : NSObject
- (WDSHTTPConnection *)startWithRequest:(NSURLRequest *)request block:(void(^)(NSData *data, BOOL isCancelled))block;
@end


@interface WDSHTTPLink : NSObject

@property (nonatomic, readonly) WDSHTTPSession *session;
@property (nonatomic, readonly) WDSCache *cache;
@property (nonatomic, readonly) WDSParser *parser;
@property (nonatomic, readonly) NSSet *forceSet;

- (id)initWithSession:(WDSHTTPSession *)session cache:(WDSCache *)cache parser:(WDSParser *)parser;

- (void)forceKey:(NSString *)key;
- (void)forceURL:(NSURL *)url;
- (void)forceRequest:(NSURLRequest *)request;

- (id)objectForURL:(NSURL *)url force:(BOOL)force block:(void(^)(id object, BOOL cancelled))block;
- (id)objectForRequest:(NSURLRequest *)request force:(BOOL)force block:(void(^)(id object, BOOL cancelled))block;
- (id)objectForRequest:(NSURLRequest *)request key:(NSString *)key force:(BOOL)force block:(void(^)(id, BOOL))block;

- (id)dataForURL:(NSURL *)url force:(BOOL)force block:(void(^)(NSData *data, BOOL cancelled))block;
- (id)dataForRequest:(NSURLRequest *)request force:(BOOL)force block:(void(^)(NSData *data, BOOL cancelled))block;
- (id)dataForRequest:(NSURLRequest *)request key:(NSString *)key force:(BOOL)force block:(void(^)(NSData *, BOOL))block;

@end