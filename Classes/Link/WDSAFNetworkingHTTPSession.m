//
//  WDSAFNetworkingHTTPSession.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSAFNetworkingHTTPSession.h"
#import "AFURLConnectionOperation.h"


@interface WDSAFNetworkingHTTPConnection : WDSHTTPConnection
@property (nonatomic, readonly) AFURLConnectionOperation *operation;
@end


@implementation WDSAFNetworkingHTTPConnection

- (id)initWithRequest:(NSURLRequest *)request block:(void(^)(NSData *, BOOL))block
{
    self = [super init];
    if (self) {
        _operation = [[AFURLConnectionOperation alloc] initWithRequest:request];
        AFURLConnectionOperation *operation = _operation;
        _operation.completionBlock = ^{
            operation.completionBlock = nil;
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)operation.response;
            NSData *data = response.statusCode == 200 ? operation.responseData : nil;
            BOOL isCancelled = operation.isCancelled || (operation.error.code == NSURLErrorCancelled);
            if (block) block(data, isCancelled);
        };
    }
    return self;
}

- (void)startWithQueue:(NSOperationQueue *)queue
{
    [queue addOperation:_operation];
}

- (void)cancel
{
    [_operation cancel];
}

@end


@implementation WDSAFNetworkingHTTPSession

- (id)init
{
    return [self initWithConcurrent:NSOperationQueueDefaultMaxConcurrentOperationCount];
}

- (id)initWithConcurrent:(NSUInteger)concurrent
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = concurrent;
    return [self initWithQueue:queue];
}

- (id)initWithQueue:(NSOperationQueue *)queue
{
    self = [super init];
    if (self) {
        _queue = queue;
    }
    return self;
}

- (WDSHTTPConnection *)startWithRequest:(NSURLRequest *)request block:(void (^)(NSData *, BOOL))block
{
    if (!request || !request.URL) { if (block) block(nil, NO); return nil; }
    WDSAFNetworkingHTTPConnection *result = [[WDSAFNetworkingHTTPConnection alloc] initWithRequest:request block:block];
    [result startWithQueue:_queue];
    return result;
}

@end
