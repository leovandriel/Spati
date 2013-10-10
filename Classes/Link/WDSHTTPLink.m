//
//  WDSHTTPLink.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSHTTPLink.h"
#import "AFURLConnectionOperation.h"
#import "NWLCore.h"
#import "WDSParser.h"
#import "WDSSyncCache.h"


@interface WDSHTTPConnectionProxy : NSObject
@property (nonatomic, readonly) NSURLRequest *request;
@property (nonatomic, readonly) NSOperationQueue *queue;
@property (nonatomic, readonly) void(^block)(NSHTTPURLResponse *response, NSData *data, BOOL cancelled);
@property (nonatomic, readonly) AFURLConnectionOperation *operation;
@property (nonatomic, readonly) BOOL isCancelled;
@end
@implementation WDSHTTPConnectionProxy

- (id)initWithRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue block:(void(^)(NSHTTPURLResponse *response, NSData *data, BOOL cancelled))block
{
    self = [super init];
    if (self) {
        _request = request;
        _queue = queue;
        _block = [block copy];
    }
    return self;
}

- (void)start
{
    _operation = [[AFURLConnectionOperation alloc] initWithRequest:_request];
    WDSHTTPConnectionProxy *p = self;
    _operation.completionBlock = ^{ [p callBlock:p.operation.isCancelled || (p.operation.error.code == NSURLErrorCancelled)]; };
    [_queue addOperation:_operation];
}

- (void)cancel
{
    [_operation cancel];
    [self callBlock:YES];
}

- (void)callBlock:(BOOL)cancelled
{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)_operation.response;
    NSData *data = _operation.responseData;
    _isCancelled = YES;
    void(^b)(NSHTTPURLResponse *response, NSData *data, BOOL cancelled) = _block; _block = nil;
    if (b) b(response, data, cancelled);
}

- (void)nilBlock
{
    _block = nil;
}

@end

@interface WDSHTTPLink ()
@property (nonatomic, readonly) NSMutableSet *forceSet;
@end

@implementation WDSHTTPLink

- (id)initWithCache:(WDSSyncCache *)cache parser:(WDSParser *)parser
{
    return [self initWithCache:cache parser:parser concurrent:NSOperationQueueDefaultMaxConcurrentOperationCount];
}

- (id)initWithCache:(WDSSyncCache *)cache parser:(WDSParser *)parser concurrent:(NSUInteger)concurrent
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = concurrent;
    return [self initWithCache:cache parser:parser queue:queue];
}

- (id)initWithCache:(WDSSyncCache *)cache parser:(WDSParser *)parser queue:(NSOperationQueue *)queue
{
    self = [super init];
    if (self) {
        _cache = cache;
        _parser = parser;
        _queue = queue;
    }
    return self;
}

- (void)forceFetchForRequest:(NSURLRequest *)request
{
    if (!_forceSet) _forceSet = [NSMutableSet set];
    NSString *key = request.URL.absoluteString;
    [_forceSet addObject:key];
}

- (BOOL)removeForceForRequest:(NSURLRequest *)request
{
    NSString *key = request.URL.absoluteString;
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
    if (!request) { if (block) block(nil, NO); return nil; }
    WDSHTTPConnectionProxy *result = [self fetchObjectForRequest:request block:block];
    if ([self removeForceForRequest:request] || force) {
        [result start];
    } else {
        NSString *key = request.URL.absoluteString;
        [_cache objectForKey:key block:^(id object) {
            if (object || result.isCancelled) { [result nilBlock]; if (block) block(object, result.isCancelled); return; }
            [result start];
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
    if (!request) { if (block) block(nil, NO); return nil; }
    WDSHTTPConnectionProxy *result = [self fetchDataForRequest:request block:block];
    if ([self removeForceForRequest:request] || force) {
        [result start];
    } else {
        NSString *key = request.URL.absoluteString;
        [_cache dataForKey:key block:^(NSData *data) {
            if (data || result.isCancelled) { [result nilBlock]; if (block) block(data, result.isCancelled); return; }
            [result start];
        }];
    }
    return result;
}

- (WDSHTTPConnectionProxy *)fetchObjectForRequest:(NSURLRequest *)request block:(void(^)(id, BOOL))block
{
    return [self fetchDataForRequest:request block:^(NSData *data, BOOL cancelled) {
        if (block) block([_parser parse:data], cancelled);
    }];
}

- (WDSHTTPConnectionProxy *)fetchDataForRequest:(NSURLRequest *)request block:(void(^)(NSData *, BOOL))block
{
    return [[WDSHTTPConnectionProxy alloc] initWithRequest:request queue:_queue block:^(NSHTTPURLResponse *response, NSData *data, BOOL cancelled) {
        if (response.statusCode == 200 && !cancelled) {
            [_cache setData:data forKey:request.URL.absoluteString block:^(BOOL done) { NWAssert(done); }];
            if (block) block(data, cancelled);
        } else {
            NWLogWarnIfNot(response.statusCode == 0 || cancelled, @"HTTP status code %i", (int)response.statusCode);
            if (block) block(nil, cancelled);
        }
    }];
}

@end
