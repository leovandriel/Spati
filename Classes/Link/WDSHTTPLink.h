//
//  WDSHTTPLink.h
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDSCache, WDSSyncCache, WDSParser;


@interface WDSHTTPConnection : NSObject
- (void)cancel;
@end


@interface WDSHTTPSession : NSObject
- (WDSHTTPConnection *)startWithRequest:(NSURLRequest *)request block:(void(^)(NSData *data, BOOL isCancelled))block;
@end


@interface WDSHTTPFetch : NSObject
@property (nonatomic, readonly) BOOL isCancelled;
- (void)cancel;
@end


@interface WDSHTTPLink : NSObject

@property (nonatomic, readonly) WDSHTTPSession *session;
@property (nonatomic, readonly) WDSCache *readCache;
@property (nonatomic, readonly) WDSCache *writeCache;
@property (nonatomic, readonly) WDSParser *parser;
@property (nonatomic, readonly) NSSet *forceSet;
@property (nonatomic, readonly) BOOL hasSyncCache;

- (id)initWithSession:(WDSHTTPSession *)session cache:(WDSCache *)cache parser:(WDSParser *)parser;
- (id)initWithSession:(WDSHTTPSession *)session syncCache:(WDSSyncCache *)syncCache parser:(WDSParser *)parser;
- (id)initWithSession:(WDSHTTPSession *)session readCache:(WDSCache *)readCache writeCache:(WDSCache *)writeCache parser:(WDSParser *)parser;
- (id)initWithSession:(WDSHTTPSession *)session readSyncCache:(WDSSyncCache *)readSyncCache writeCache:(WDSCache *)writeCache parser:(WDSParser *)parser;

- (void)forceKey:(NSString *)key;
- (void)forceURL:(NSURL *)url;
- (void)forceRequest:(NSURLRequest *)request;

- (WDSHTTPFetch *)objectForURL:(NSURL *)url force:(BOOL)force block:(void(^)(id object, WDSHTTPFetch *fetch))block;
- (WDSHTTPFetch *)objectForRequest:(NSURLRequest *)request force:(BOOL)force block:(void(^)(id object, WDSHTTPFetch *fetch))block;
- (WDSHTTPFetch *)objectForRequest:(NSURLRequest *)request key:(NSString *)key force:(BOOL)force block:(void(^)(id, WDSHTTPFetch *fetch))block;
- (WDSHTTPFetch *)dataForURL:(NSURL *)url force:(BOOL)force block:(void(^)(NSData *data, WDSHTTPFetch *fetch))block;
- (WDSHTTPFetch *)dataForRequest:(NSURLRequest *)request force:(BOOL)force block:(void(^)(NSData *data, WDSHTTPFetch *fetch))block;
- (WDSHTTPFetch *)dataForRequest:(NSURLRequest *)request key:(NSString *)key force:(BOOL)force block:(void(^)(NSData *, WDSHTTPFetch *fetch))block;
- (WDSHTTPFetch *)objectForRequest:(NSURLRequest *)request key:(NSString *)key force:(BOOL)force dataOnly:(BOOL)dataOnly block:(void(^)(id, WDSHTTPFetch *fetch))block;

@end
