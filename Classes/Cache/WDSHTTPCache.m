//
//  WDSHTTPCache.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSHTTPCache.h"
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
    dispatch_async(_serial, ^{
        _isCancelled = YES;
        void(^b)(NSHTTPURLResponse *response, NSData *data, BOOL cancelled) = _block; _block = nil;
        if (b) b(response, data, cancelled);
    });
}

@end

@interface WDSHTTPCache ()
@property (nonatomic, readonly) NSMutableSet *forceSet;
@property (nonatomic, readonly) dispatch_queue_t serial;
@end

@implementation WDSHTTPCache

- (id)initWithCaches:(NSArray *)caches
{
    return [self initWithCaches:caches concurrent:NSOperationQueueDefaultMaxConcurrentOperationCount];
}

- (id)initWithCaches:(NSArray *)caches concurrent:(NSUInteger)concurrent
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = concurrent;
    return [self initWithCaches:caches queue:queue];
}

- (id)initWithCaches:(NSArray *)caches queue:(NSOperationQueue *)queue
{
    self = [super initWithCaches:caches];
    if (self) {
        _queue = queue;
        _serial = dispatch_queue_create("WDSHTTPCache", DISPATCH_QUEUE_SERIAL);
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
        [super objectForKey:key block:^(id object) {
            if (object || result.isCancelled) { if (block) block(object, result.isCancelled); return; }
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
        [super dataForKey:key block:^(NSData *data) {
            if (data || result.isCancelled) { if (block) block(data, result.isCancelled); return; }
            [result start];
        }];
    }
    return result;
}

- (WDSHTTPConnectionProxy *)fetchObjectForKey:(NSString *)key block:(void(^)(id, BOOL))block
{
    return [self fetchDataForKey:key block:^(NSData *data, BOOL cancelled) {
        dispatch_async(self.workQueueOrDefault, ^{
            id object = data ? [self objectForKey:key] : nil;
            if (block) dispatch_async(self.doneQueueOrDefault, ^{ block(object, cancelled); });
        });
    }];
}

- (WDSHTTPConnectionProxy *)fetchDataForKey:(NSString *)key block:(void(^)(NSData *, BOOL))block
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[self urlForKey:key]];
    return [[WDSHTTPConnectionProxy alloc] initWithRequest:request queue:_queue serial:_serial block:^(NSHTTPURLResponse *response, NSData *data, BOOL cancelled) {
        if (response.statusCode == 200 && !cancelled) {
            dispatch_async(self.workQueueOrDefault, ^{
                BOOL success = [self setData:data forKey:key];
                NWAssert(success);
                if (block) dispatch_async(self.doneQueueOrDefault, ^{ block(data, cancelled); });
            });
        } else {
            NWLogWarnIfNot(response.statusCode == 0 || cancelled, @"HTTP status code %i", (int)response.statusCode);
            if (block) dispatch_async(self.doneQueueOrDefault, ^{ block(nil, cancelled); });
        }
    }];
}

@end
