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


@interface WDSCache ()
@property (nonatomic, readonly) dispatch_queue_t workQueueOrDefault;
@property (nonatomic, readonly) dispatch_queue_t doneQueueOrDefault;
@end


@interface WDSHTTPConnectionProxy : NSObject
@property (nonatomic, readonly) NSURLRequest *request;
@property (nonatomic, readonly) NSOperationQueue *queue;
@property (nonatomic, readonly) dispatch_queue_t serial;
@property (nonatomic, readonly) void(^block)(NSHTTPURLResponse *response, NSData *data, BOOL cancelled);
@property (nonatomic, readonly) AFURLConnectionOperation *operation;
@property (nonatomic, readonly) BOOL isCancelled;
@end
@implementation WDSHTTPConnectionProxy

- (id)initWithRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue serial:(dispatch_queue_t)serial block:(void(^)(NSHTTPURLResponse *response, NSData *data, BOOL cancelled))block
{
    self = [super init];
    if (self) {
        _request = request;
        _queue = queue;
        _serial = serial;
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
@property (nonatomic, readonly) dispatch_queue_t serial;
@end

@implementation WDSHTTPLink

- (id)initWithCache:(WDSCache *)cache
{
    return [self initWithCache:cache concurrent:NSOperationQueueDefaultMaxConcurrentOperationCount];
}

- (id)initWithCache:(WDSCache *)cache concurrent:(NSUInteger)concurrent
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = concurrent;
    return [self initWithCache:cache queue:queue];
}

- (id)initWithCache:(WDSCache *)cache queue:(NSOperationQueue *)queue
{
    self = [super init];
    if (self) {
        _cache = cache;
        _queue = queue;
        _serial = dispatch_queue_create("WDSHTTPLink", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)forceFetchForKey:(NSString *)key
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

- (NSURL *)urlForKey:(NSString *)key
{
    return _baseURL ? [NSURL URLWithString:key relativeToURL:_baseURL] : [NSURL URLWithString:key];
}

- (id)objectForKey:(NSString *)key force:(BOOL)force block:(void(^)(id, BOOL))block
{
    if (!key) { if (block) block(nil, NO); return nil; }
    WDSHTTPConnectionProxy *result = [self fetchObjectForKey:key block:block];
    if ([self removeForceForKey:key] || force) {
        [result start];
    } else {
        [_cache objectForKey:key block:^(id object) {
            if (object || result.isCancelled) { [result nilBlock]; if (block) block(object, result.isCancelled); return; }
            [result start];
        }];
    }
    return result;
}

- (id)dataForKey:(NSString *)key force:(BOOL)force block:(void(^)(NSData *, BOOL))block
{
    if (!key) { if (block) block(nil, NO); return nil; }
    WDSHTTPConnectionProxy *result = [self fetchDataForKey:key block:block];
    if ([self removeForceForKey:key] || force) {
        [result start];
    } else {
        [_cache dataForKey:key block:^(NSData *data) {
            if (data || result.isCancelled) { [result nilBlock]; if (block) block(data, result.isCancelled); return; }
            [result start];
        }];
    }
    return result;
}

- (WDSHTTPConnectionProxy *)fetchObjectForKey:(NSString *)key block:(void(^)(id, BOOL))block
{
    return [self fetchDataForKey:key block:^(NSData *data, BOOL cancelled) {
        dispatch_async(_cache.workQueueOrDefault, ^{
            id object = data ? [_cache objectForKey:key] : nil;
            if (block) dispatch_async(_cache.doneQueueOrDefault, ^{ block(object, cancelled); });
        });
    }];
}

- (WDSHTTPConnectionProxy *)fetchDataForKey:(NSString *)key block:(void(^)(NSData *, BOOL))block
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self urlForKey:key]];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData | NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    return [[WDSHTTPConnectionProxy alloc] initWithRequest:request queue:_queue serial:_serial block:^(NSHTTPURLResponse *response, NSData *data, BOOL cancelled) {
        if (response.statusCode == 200 && !cancelled) {
            dispatch_async(_cache.workQueueOrDefault, ^{
                BOOL success = [_cache setData:data forKey:key];
                NWAssert(success);
                if (block) dispatch_async(_cache.doneQueueOrDefault, ^{ block(data, cancelled); });
            });
        } else {
            NWLogWarnIfNot(response.statusCode == 0 || cancelled, @"HTTP status code %i", (int)response.statusCode);
            if (block) dispatch_async(_cache.doneQueueOrDefault, ^{ block(nil, cancelled); });
        }
    }];
}

@end
