//
//  WDSAFNetworkingHTTPSession.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSAFNetworkingHTTPSession.h"
#import "AFURLConnectionOperation.h"


@interface WDSAFNetworkingHTTPConnection : NSObject<WDSCancel>
@property (nonatomic, readonly) AFURLConnectionOperation *operation;
@end


@implementation WDSAFNetworkingHTTPConnection

- (instancetype)initWithRequest:(NSURLRequest *)request block:(void(^)(NSData *, BOOL))block
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

- (BOOL)isCancelled
{
    return _operation.isCancelled || (_operation.error.code == NSURLErrorCancelled);
}

@end


@implementation WDSAFNetworkingHTTPSession

- (instancetype)init
{
    return [self initWithConcurrent:NSOperationQueueDefaultMaxConcurrentOperationCount];
}

- (instancetype)initWithConcurrent:(NSUInteger)concurrent
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = concurrent;
    return [self initWithQueue:queue];
}

- (instancetype)initWithQueue:(NSOperationQueue *)queue
{
    self = [super init];
    if (self) {
        _queue = queue;
    }
    return self;
}

- (id<WDSCancel>)startWithRequest:(NSURLRequest *)request block:(void (^)(NSData *, BOOL))block
{
    if (!request || !request.URL) { if (block) block(nil, NO); return nil; }
    WDSAFNetworkingHTTPConnection *result = [[WDSAFNetworkingHTTPConnection alloc] initWithRequest:request block:block];
    [result startWithQueue:_queue];
    return result;
}

@end
