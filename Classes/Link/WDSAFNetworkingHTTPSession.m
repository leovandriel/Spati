//
//  WDSAFNetworkingHTTPSession.m
//  Spati
//
//  Copyright (c) 2013 Wit Dot Media Berlin GmbH. All rights reserved.
//

#import "WDSAFNetworkingHTTPSession.h"
#import "AFURLConnectionOperation.h"
#import "NWLCore.h"


@interface WDSAFNetworkingHTTPConnection : NSObject<WDSCancel>
@property (nonatomic, readonly) AFURLConnectionOperation *operation;
@end


@implementation WDSAFNetworkingHTTPConnection

- (instancetype)initWithRequest:(NSURLRequest *)request block:(void(^)(NSData *, WDSStatus))block
{
    self = [super init];
    if (self) {
        _operation = [[AFURLConnectionOperation alloc] initWithRequest:request];
        AFURLConnectionOperation *operation = _operation;
        _operation.completionBlock = ^{
            operation.completionBlock = nil;
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)operation.response;
            NSData *data = operation.responseData;
            BOOL isCancelled = operation.isCancelled || (operation.error.code == NSURLErrorCancelled);
            if (data && response.statusCode != 200) {
                NWLogInfo(@"returing nil after http status code: %i  data-size: %i  cancelled: %i", (int)response.statusCode, (int)data.length, isCancelled);
                data = nil;
            }
            if (!data.length && response.statusCode == 200) {
                NWLogWarn(@"got 200 but no data, data is %@", data ? @"not-nil" : @"nil");
            }
            WDSStatus status = isCancelled ? WDSStatusCancelled : [WDSAFNetworkingHTTPConnection statusWithHTTPStatus:response.statusCode];
            if (block) block(data, status);
        };
    }
    return self;
}

+ (WDSStatus)statusWithHTTPStatus:(NSUInteger)statusCode
{
    switch (statusCode) {
        case 200: return WDSStatusSuccess;
        case 403: return WDSStatusNotFound;
        case 404: return WDSStatusNotFound;
    }
    return WDSStatusFailed;
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

- (id<WDSCancel>)startWithRequest:(NSURLRequest *)request block:(void (^)(NSData *, WDSStatus))block
{
    if (!request || !request.URL) { if (block) block(nil, WDSStatusFailed); return nil; }
    WDSAFNetworkingHTTPConnection *result = [[WDSAFNetworkingHTTPConnection alloc] initWithRequest:request block:block];
    [result startWithQueue:_queue];
    return result;
}

@end
