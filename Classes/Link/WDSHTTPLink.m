//
//  WDSHTTPLink.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSHTTPLink.h"
#import "NWLCore.h"
#import "WDSParser.h"
#import "WDSSyncCache.h"


@interface WDSHTTPProcess : NSObject
@property (nonatomic, strong) WDSHTTPConnection *connection;
@property (nonatomic, copy) void(^block)(NSData *data, BOOL cancelled);
@property (nonatomic, readonly) BOOL isCancelled;
- (void)cancel;
- (void)callBlockWithData:(NSData *)data isCancelled:(BOOL)isCancelled;
- (void)nilBlock;
@end


@implementation WDSHTTPLink {
    NSMutableSet *_forceSet;
}

- (id)initWithSession:(WDSHTTPSession *)session cache:(WDSCache *)cache parser:(WDSParser *)parser
{
    self = [super init];
    if (self) {
        _cache = cache;
        _parser = parser;
        _session = session;
    }
    return self;
}

- (void)forceRequest:(NSURLRequest *)request
{
    [self forceURL:request.URL];
}

- (void)forceURL:(NSURL *)url
{
    [self forceKey:url.absoluteString];
}

- (void)forceKey:(NSString *)key
{
    if (!_forceSet) _forceSet = [NSMutableSet set];
    [_forceSet addObject:key];
}

- (BOOL)removeForceForKey:(NSString *)key
{
    BOOL result = [_forceSet containsObject:key];
    [_forceSet removeObject:key];
    return result;
}

#pragma mark - Retrieval

- (id)objectForURL:(NSURL *)url force:(BOOL)force block:(void (^)(id, BOOL))block
{
    return [self objectForRequest:[NSURLRequest requestWithURL:url] force:force block:block];
}

- (id)objectForRequest:(NSURLRequest *)request force:(BOOL)force block:(void(^)(id, BOOL))block
{
    return [self objectForRequest:request key:request.URL.absoluteString force:force block:block];
}

- (id)objectForRequest:(NSURLRequest *)request key:(NSString *)key force:(BOOL)force block:(void(^)(id, BOOL))block
{
    if (!request) { if (block) block(nil, NO); return nil; }
    WDSHTTPProcess *result = [[WDSHTTPProcess alloc] init];
    if ([self removeForceForKey:key] || force) {
        [self fetchObjectForRequest:request key:key process:result block:block];
    } else {
        [_cache objectForKey:key block:^(id object) {
            if (object || result.isCancelled) { [result nilBlock]; if (block) block(object, result.isCancelled); return; }
            [self fetchObjectForRequest:request key:key process:result block:block];
        }];
    }
    return result;
}

- (id)dataForURL:(NSURL *)url force:(BOOL)force block:(void (^)(NSData *, BOOL))block
{
    return [self dataForRequest:[NSURLRequest requestWithURL:url] force:force block:block];
}

- (id)dataForRequest:(NSURLRequest *)request force:(BOOL)force block:(void(^)(NSData *, BOOL))block
{
    return [self dataForRequest:request key:request.URL.absoluteString force:force block:block];
}

- (id)dataForRequest:(NSURLRequest *)request key:(NSString *)key force:(BOOL)force block:(void(^)(NSData *, BOOL))block
{
    if (!request) { if (block) block(nil, NO); return nil; }
    WDSHTTPProcess *result = [[WDSHTTPProcess alloc] init];
    if ([self removeForceForKey:key] || force) {
        [self fetchDataForRequest:request key:key process:result block:block];
    } else {
        [_cache dataForKey:key block:^(NSData *data) {
            if (data || result.isCancelled) { [result nilBlock]; if (block) block(data, result.isCancelled); return; }
            [self fetchDataForRequest:request key:key process:result block:block];
        }];
    }
    return result;
}

- (void)fetchObjectForRequest:(NSURLRequest *)request key:(NSString *)key process:(WDSHTTPProcess *)process block:(void(^)(id, BOOL))block
{
    return [self fetchDataForRequest:request key:key process:process block:^(NSData *data, BOOL cancelled) {
        if (block) block([_parser parse:data], cancelled);
    }];
}

- (void)fetchDataForRequest:(NSURLRequest *)request key:(NSString *)key process:(WDSHTTPProcess *)process block:(void(^)(NSData *, BOOL))block
{
    process.block = ^(NSData *data, BOOL isCancelled) {
        if (data && !isCancelled) {
            [_cache setData:data forKey:key block:^(BOOL done) { NWAssert(done); }];
            if (block) block(data, isCancelled);
        } else {
            NWAssert(isCancelled);
            if (block) block(nil, isCancelled);
        }
    };
    process.connection = [_session startWithRequest:request block:^(NSData *data, BOOL isCancelled) {
        [process callBlockWithData:data isCancelled:isCancelled];
    }];
}

@end


@implementation WDSHTTPProcess

- (void)cancel
{
    _isCancelled = YES;
    [_connection cancel];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self callBlockWithData:nil isCancelled:YES];
//    });
}

- (void)callBlockWithData:(NSData *)data isCancelled:(BOOL)isCancelled
{
    _isCancelled |= isCancelled;
    void(^b)(NSData *data, BOOL cancelled) = _block; _block = nil;
    if (b) b(data, isCancelled);
}

- (void)nilBlock
{
    _block = nil;
}

@end


@implementation WDSHTTPConnection

- (void)cancel
{
}

@end


@implementation WDSHTTPSession

- (WDSHTTPConnection *)startWithRequest:(NSURLRequest *)request block:(void(^)(NSData *, BOOL))block
{
    return nil;
}

@end
